resource "aws_elasticsearch_domain" "this" {
  domain_name = "ssang"
  elasticsearch_version = "OpenSearch_1.2"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  provider = aws.free-tier
}