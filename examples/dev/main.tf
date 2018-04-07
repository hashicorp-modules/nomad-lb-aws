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
  vpc_cidrs_public  = ["${var.vpc_cidrs_public}"]
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = ["${var.vpc_cidrs_private}"]
  bastion_count     = "${var.bastion_count}"
  image_id          = "${data.aws_ami.base.id}"
  tags              = "${var.tags}"
}

module "nomad_lb_aws" {
  # source = "github.com/hashicorp-modules/nomad-lb-aws?ref=f-refactor"
  source = "../../../nomad-lb-aws"

  name           = "${var.name}"
  vpc_id         = "${module.network_aws.vpc_id}"
  cidr_blocks    = ["${module.network_aws.vpc_cidr}"]
  subnet_ids     = ["${module.network_aws.subnet_public_ids}"]
  is_internal_lb = "${var.is_internal_lb}"
  tags           = "${var.tags}"
}
