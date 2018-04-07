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
  # source = "github.com/hashicorp-modules/network-aws?ref=f-refactor"
  source = "../../../network-aws"

  name              = "${var.name}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  bastion_count     = "${var.bastion_count}"
  image_id          = "${data.aws_ami.base.id}"
  tags              = "${var.tags}"
}

module "tls_self_signed_cert" {
  # source = "github.com/hashicorp-modules/tls-self-signed-cert?ref=f-refactor"
  source = "../../../tls-self-signed-cert"

  validity_period_hours = "12"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["hashicorp.com"]
  ip_addresses          = ["127.0.0.1",]
}

module "nomad_lb_aws" {
  # source = "github.com/hashicorp-modules/nomad-lb-aws?ref=f-refactor"
  source = "../../../nomad-lb-aws"

  create         = "${var.create}"
  name           = "${var.name}"
  vpc_id         = "${module.network_aws.vpc_id}"
  cidr_blocks    = ["${module.network_aws.vpc_cidr}"]
  subnet_ids     = ["${module.network_aws.subnet_private_ids}"]
  is_internal_lb = "${var.is_internal_lb}"
  use_lb_cert    = "${var.use_lb_cert}"
  lb_cert        = "${module.tls_self_signed_cert.leaf_cert_pem}"
  lb_private_key = "${module.tls_self_signed_cert.leaf_private_key_pem}"
  lb_ssl_policy  = "${var.lb_ssl_policy}"
  tags           = "${var.tags}"
}

