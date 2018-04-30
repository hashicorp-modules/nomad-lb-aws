output "nomad_lb_sg_id" {
  value = "${module.nomad_lb_aws.nomad_lb_sg_id}"
}

output "nomad_lb_dns" {
  value = "${module.nomad_lb_aws.nomad_lb_dns}"
}

output "nomad_tg_http_4646_arn" {
  value = "${module.nomad_lb_aws.nomad_tg_http_4646_arn}"
}
