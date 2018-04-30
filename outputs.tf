output "nomad_lb_sg_id" {
  value = "${element(concat(aws_security_group.nomad_lb.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_http_4646_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_http_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_https_4646_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_https_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_lb_dns" {
  value = "${element(concat(aws_lb.nomad.*.dns_name, list("")), 0)}" # TODO: Workaround for issue #11210
}
