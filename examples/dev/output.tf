output "nomad_lb_sg_id" {
  value = "${module.nomad_lb_aws.nomad_lb_sg_id}"
}

output "nomad_lb_dns" {
  value = "${module.nomad_lb_aws.nomad_lb_dns}"
}

output "nomad_http_4646_target_group" {
  value = "${module.nomad_lb_aws.nomad_http_4646_target_group}"
}
