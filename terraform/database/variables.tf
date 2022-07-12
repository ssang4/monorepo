variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "ingress_cidr_blocks" {
  type = list(string)
}