data "aws_caller_identity" "this" {}

module "vault-iam-user" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.2.0"

  name = "vault"

  create_iam_user_login_profile = false
}

module "vault-iam-policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.2.0"

  name = "vault"
  
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/*"]
    }
  ]
}
EOT
}

resource "aws_iam_user_policy_attachment" "vault" {
  user = module.vault-iam-user.iam_user_name
  policy_arn = module.vault-iam-policy.arn
}

module "external-dns-iam-user" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.2.0"

  name = "external-dns"

  create_iam_user_login_profile = false
}

module "external-dns-iam-policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.2.0"

  name = "external-dns"
  
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOT
}

resource "aws_iam_user_policy_attachment" "external-dns" {
  user = module.external-dns-iam-user.iam_user_name
  policy_arn = module.external-dns-iam-policy.arn
}