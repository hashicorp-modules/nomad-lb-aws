data "aws_ami" "base" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network_aws" {
  # source = "github.com/hashicorp-modules/network-aws"
  source = "../../../network-aws"

  name              = "${var.name}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  bastion_count     = "${var.bastion_count}"
  image_id          = "${data.aws_ami.base.id}"
  tags              = "${var.tags}"
}

module "root_tls_self_signed_ca" {
  # source = "github.com/hashicorp-modules/tls-self-signed-cert"
  source = "../../../tls-self-signed-cert"

  name                  = "root"
  validity_period_hours = "12"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["hashicorp.com"]
  ip_addresses          = ["127.0.0.1",]
  download_certs        = true
}

module "leaf_tls_self_signed_cert" {
  # source = "github.com/hashicorp-modules/tls-self-signed-cert"
  source = "../../../tls-self-signed-cert"

  name                  = "leaf"
  validity_period_hours = "12"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["hashicorp.com"]
  ip_addresses          = ["127.0.0.1",]
  download_certs        = true

  ca_override      = true
  ca_key_override  = "${module.root_tls_self_signed_ca.ca_private_key_pem}"
  ca_cert_override = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  download_certs   = true
}

resource "random_id" "lb_access_logs" {
  byte_length = 8
  prefix      = "${format("%s-lb-access-logs-", var.name)}"
}

data "aws_elb_service_account" "lb_access_logs" {}

resource "aws_s3_bucket" "lb_access_logs" {
  bucket = "${random_id.lb_access_logs.hex}"
  acl    = "private"
  tags   = "${merge(var.tags, map("Name", format("%s-lb-access-logs", var.name)))}"

  force_destroy = true

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LBAccessLogs",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${random_id.lb_access_logs.hex}/${var.lb_logs_prefix}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.lb_access_logs.arn}"
        ]
      }
    }
  ]
}
POLICY
}

module "nomad_lb_aws" {
  # source = "github.com/hashicorp-modules/nomad-lb-aws"
  source = "../../../nomad-lb-aws"

  create          = "${var.create}"
  name            = "${var.name}"
  vpc_id          = "${module.network_aws.vpc_id}"
  cidr_blocks     = ["${module.network_aws.vpc_cidr}"]
  subnet_ids      = ["${module.network_aws.subnet_private_ids}"]
  is_internal_lb  = "${var.is_internal_lb}"
  use_lb_cert     = "${var.use_lb_cert}"
  lb_cert         = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
  lb_private_key  = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
  lb_cert_chain   = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  lb_ssl_policy   = "${var.lb_ssl_policy}"
  lb_logs_bucket  = "${aws_s3_bucket.lb_access_logs.id}"
  lb_logs_prefix  = "${var.lb_logs_prefix}"
  lb_logs_enabled = "${var.lb_logs_enabled}"
  tags            = "${var.tags}"
}
