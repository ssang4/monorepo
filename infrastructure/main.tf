module "route53-zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.9.0"

  zones = {
    "ssang.io" = {}
  }
}

module "route53-zone-ssang-io-records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.9.0"

  zone_name = keys(module.route53-zones.route53_zone_zone_id)[0]

  records = concat([
    {
      name = ""
      type = "TXT"
      ttl  = 300
      records = [
        "protonmail-verification=b86f23bf8f37d2c3a9293056e1461267b33aee81",
        "v=spf1 include:_spf.protonmail.ch mx include:amazonses.com ~all",
      ]
    },
    {
      name = ""
      type = "MX"
      ttl  = 300
      records = [
        "10 mail.protonmail.ch",
        "20 mailsec.protonmail.ch",
      ]
    },
    {
      name = "protonmail._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
    {
      name = "protonmail2._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail2.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
    {
      name = "protonmail3._domainkey"
      type = "CNAME"
      ttl  = 300
      records = [
        "protonmail3.domainkey.dkkgf6iqytwe7gvfpqlrveuupy4oqrfn5oatiircsi7sp4zodrcxq.domains.proton.ch."
      ]
    },
    ], [
    for dkim_token in aws_ses_domain_dkim.keycloak.dkim_tokens : {
      name = "${dkim_token}._domainkey.keycloak"
      type = "CNAME"
      ttl  = 300
      records = [
        "${dkim_token}.dkim.amazonses.com"
      ]
    }
    ], [
    for dkim_token in aws_ses_domain_dkim.alertmanager.dkim_tokens : {
      name = "${dkim_token}._domainkey.alertmanager"
      type = "CNAME"
      ttl  = 300
      records = [
        "${dkim_token}.dkim.amazonses.com"
      ]
    }
    ]
  )
}

data "digitalocean_kubernetes_versions" "this" {
  version_prefix = "1.24."
}

resource "digitalocean_kubernetes_cluster" "this" {
  name         = "ssang"
  region       = "fra1"
  version      = data.digitalocean_kubernetes_versions.this.latest_version
  auto_upgrade = true

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
  }

  maintenance_policy {
    day        = "sunday"
    start_time = "00:00"
  }
}

module "kms-vault-unseal" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  aliases = [
    "vault/unseal"
  ]
}

module "iam-policy-vault-unseal" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name = "vault-unseal"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "${module.kms-vault-unseal.key_arn}"
    }
  ]
}
EOT
}

module "iam-user-vault" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.4.0"

  name = "vault"

  create_iam_user_login_profile = false
}

resource "aws_iam_user_policy_attachment" "vault-unseal" {
  user       = module.iam-user-vault.iam_user_name
  policy_arn = module.iam-policy-vault-unseal.arn
}

resource "aws_iam_user_policy_attachment" "vault-dynamodb-storage" {
  user       = module.iam-user-vault.iam_user_name
  policy_arn = module.iam-policy-vault-dynamodb-storage.arn
}

module "iam-policy-external-dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name = "external-dns"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:ChangeResourceRecordSets",
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

module "iam-user-external-dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.4.0"

  name = "external-dns"

  create_iam_user_login_profile = false
}

resource "aws_iam_user_policy_attachment" "external-dns" {
  user       = module.iam-user-external-dns.iam_user_name
  policy_arn = module.iam-policy-external-dns.arn
}

resource "aws_ses_domain_identity" "keycloak" {
  domain = "keycloak.ssang.io"
}

resource "aws_ses_domain_identity" "alertmanager" {
  domain = "alertmanager.ssang.io"
}

resource "aws_ses_domain_dkim" "keycloak" {
  domain = aws_ses_domain_identity.keycloak.domain
}

resource "aws_ses_domain_dkim" "alertmanager" {
  domain = aws_ses_domain_identity.alertmanager.domain
}

module "iam-policy-keycloak-smtp" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name = "keycloak-smtp"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

module "iam-user-keycloak-smtp" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.4.0"

  name = "keycloak-smtp"

  create_iam_user_login_profile = false
}

resource "aws_iam_user_policy_attachment" "keycloak-smtp" {
  user       = module.iam-user-keycloak-smtp.iam_user_name
  policy_arn = module.iam-policy-keycloak-smtp.arn
}

module "iam-policy-alertmanager-smtp" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name = "alertmanager-smtp"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

module "iam-user-alertmanager-smtp" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.4.0"

  name = "alertmanager-smtp"

  create_iam_user_login_profile = false
}

resource "aws_iam_user_policy_attachment" "alertmanager-smtp" {
  user       = module.iam-user-alertmanager-smtp.iam_user_name
  policy_arn = module.iam-policy-alertmanager-smtp.arn
}

resource "aws_iam_saml_provider" "keycloak" {
  name = "keycloak"
  saml_metadata_document = file("${path.module}/files/keycloak-saml-metadata.xml")
}

module "iam-role-saml-keycloak-admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-saml"
  version = "5.4.0"

  create_role = true

  role_name = "admin-kc"

  provider_id = aws_iam_saml_provider.keycloak.arn

  number_of_role_policy_arns = 1
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

module "dynamodb-table-vault-storage" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.1.1"

  name = "vault-storage"
  hash_key = "Path"
  range_key = "Key"

  attributes = [
    {
      name = "Path"
      type = "S"
    },
    {
      name = "Key"
      type = "S"
    },
  ]
}

module "iam-policy-vault-dynamodb-storage" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.4.0"

  name = "vault-dynamodb-storage"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:ListTables",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:CreateTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ],
      "Resource": "${module.dynamodb-table-vault-storage.dynamodb_table_arn}"
    }
  ]
}
EOT
}