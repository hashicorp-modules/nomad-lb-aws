module "nomad_lb_aws" {
  # source = "github.com/hashicorp-modules/nomad-lb-aws?ref=f-refactor"
  source = "../../../nomad-lb-aws"

  create      = false
  vpc_id      = ""
  cidr_blocks = []
  subnet_ids  = []
}
