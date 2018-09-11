output "nomad_app_lb_sg_id" {
  value = "${element(concat(aws_security_group.nomad_app_lb.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_lb_arn" {
  value = "${element(concat(aws_lb.nomad.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_app_lb_dns" {
  value = "${element(concat(aws_lb.nomad_application_lb.*.dns_name, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_network_lb_dns" {
  value = "${element(concat(aws_lb.nomad_network_lb.*.dns_name, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_tcp_22_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_tcp_22.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_tcp_4646_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_tcp_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_http_4646_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_http_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_https_4646_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_https_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_http_3030_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_http_3030.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "nomad_tg_https_3030_arn" {
  value = "${element(concat(aws_lb_target_group.nomad_https_3030.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
}
