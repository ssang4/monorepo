data "aws_caller_identity" "this" {
  provider = aws.free-tier
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "ssang"
  elasticsearch_version = "OpenSearch_1.2"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    custom_endpoint_enabled = true
    custom_endpoint = "opensearch.ft.ssang.io"
    custom_endpoint_certificate_arn = var.ft_ssang_io_acm_certificate_arn
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name = "admin"
      master_user_password = "1jq%UA4N8Mk2"
    }
  }

  provider = aws.free-tier
}

resource "aws_elasticsearch_domain_policy" "this" {
  domain_name = aws_elasticsearch_domain.this.domain_name

  access_policies = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:ESHttp*",
      "Resource": "${aws_elasticsearch_domain.this.arn}/*"
    }
  ]
}
EOT

  provider = aws.free-tier
}

resource "aws_elasticsearch_domain_saml_options" "this" {
  domain_name = aws_elasticsearch_domain.this.domain_name

  saml_options {
    enabled = true
    master_user_name = "ssang"
    master_backend_role = "opensearch-admin"
    roles_key = "role"

    idp {
      entity_id = "https://keycloak.ssang.io/realms/master"
      metadata_content = file("./idp-metadata.xml")
    }
  }

  provider = aws.free-tier
}