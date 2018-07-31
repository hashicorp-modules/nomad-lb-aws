terraform {
  required_version = ">= 0.11.6"
}

resource "aws_security_group" "nomad_lb" {
  count = "${var.create ? 1 : 0}"

  name_prefix = "${var.name}-nomad-lb-"
  description = "Security group for nomad ${var.name} LB"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", format("%s-nomad-lb", var.name)))}"
  description = "Nomad lb ports"
}

resource "aws_security_group_rule" "nomad_lb_http_80" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.nomad_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["${var.cidr_blocks}"]
  description       = "Nomad lb HTTP:80 port"
}

resource "aws_security_group_rule" "nomad_lb_https_443" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  security_group_id = "${aws_security_group.nomad_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${var.cidr_blocks}"]
  description       = "Nomad lb HTTPS:443 port"
}

resource "aws_security_group_rule" "nomad_lb_tcp_4646" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.nomad_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4646
  to_port           = 4646
  cidr_blocks       = ["${var.cidr_blocks}"]
  description       = "Nomad lb TCP:4646 port"
}

resource "aws_security_group_rule" "outbound_tcp" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.nomad_lb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Nomad lb outbound TCP ports"
}

resource "random_id" "nomad_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"

  byte_length = 4
  prefix      = "${format("%s-nomad-lb-access-logs-", var.name)}"
}

data "aws_elb_service_account" "nomad_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"
}

resource "aws_s3_bucket" "nomad_lb_access_logs" {
  count = "${var.create && !var.lb_bucket_override ? 1 : 0}"

  bucket = "${random_id.nomad_lb_access_logs.hex}"
  acl    = "private"
  tags   = "${merge(var.tags, map("Name", format("%s-nomad-lb-access-logs", var.name)))}"

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
      "Resource": "arn:aws:s3:::${random_id.nomad_lb_access_logs.hex}${var.lb_bucket_prefix != "" ? format("//", var.lb_bucket_prefix) : ""}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.nomad_lb_access_logs.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "random_id" "nomad_lb" {
  count = "${var.create ? 1 : 0}"

  byte_length = 4
  prefix      = "nomad-lb-"
}

resource "aws_lb" "nomad" {
  count = "${var.create ? 1 : 0}"

  name            = "${random_id.nomad_lb.hex}"
  internal        = "${var.is_internal_lb}"
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.nomad_lb.id}"]
  tags            = "${merge(var.tags, map("Name", format("%s-nomad-lb", var.name)))}"

  access_logs {
    bucket  = "${var.lb_bucket_override ? var.lb_bucket : element(concat(aws_s3_bucket.nomad_lb_access_logs.*.id, list("")), 0)}"
    prefix  = "${var.lb_bucket_prefix}"
    enabled = "${var.lb_logs_enabled}"
  }
}

resource "random_id" "nomad_http_4646" {
  count = "${var.create && !var.use_lb_cert ? 1 : 0}"

  byte_length = 4
  prefix      = "nomad-http-4646-"
}

resource "aws_lb_target_group" "nomad_http_4646" {
  count = "${var.create && !var.use_lb_cert ? 1 : 0}"

  name     = "${random_id.nomad_http_4646.hex}"
  vpc_id   = "${var.vpc_id}"
  port     = 4646
  protocol = "HTTP"
  tags     = "${merge(var.tags, map("Name", format("%s-nomad-http-4646", var.name)))}"

  health_check {
    interval = 15
    timeout  = 5
    protocol = "HTTP"
    port     = "traffic-port"
    path     = "/v1/agent/health"
    matcher  = "200"

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "nomad_80" {
  count = "${var.create && !var.use_lb_cert ? 1 : 0}"

  load_balancer_arn = "${aws_lb.nomad.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.nomad_http_4646.arn}"
    type             = "forward"
  }
}

resource "aws_iam_server_certificate" "nomad" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  name              = "${random_id.nomad_lb.hex}"
  certificate_body  = "${var.lb_cert}"
  private_key       = "${var.lb_private_key}"
  certificate_chain = "${var.lb_cert_chain}"
  path              = "/${var.name}-${random_id.nomad_lb.hex}/"
}

resource "random_id" "nomad_https_4646" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  byte_length = 4
  prefix      = "nomad-https-4646-"
}

resource "aws_lb_target_group" "nomad_https_4646" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  name     = "${random_id.nomad_https_4646.hex}"
  vpc_id   = "${var.vpc_id}"
  port     = 4646
  protocol = "HTTPS"
  tags     = "${merge(var.tags, map("Name", format("%s-nomad-https-4646", var.name)))}"

  health_check {
    interval = 15
    timeout  = 5
    protocol = "HTTPS"
    port     = "traffic-port"
    path     = "/v1/agent/health"
    matcher  = "200"

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "nomad_443" {
  count = "${var.create && var.use_lb_cert ? 1 : 0}"

  load_balancer_arn = "${aws_lb.nomad.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${aws_iam_server_certificate.nomad.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.nomad_https_4646.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "nomad_4646" {
  count = "${var.create ? 1 : 0}"

  load_balancer_arn = "${aws_lb.nomad.arn}"
  port              = "4646"
  protocol          = "${var.use_lb_cert ? "HTTPS" : "HTTP"}"
  ssl_policy        = "${var.use_lb_cert ? var.lb_ssl_policy : ""}"
  certificate_arn   = "${var.use_lb_cert ? element(concat(aws_iam_server_certificate.nomad.*.arn, list("")), 0) : ""}" # TODO: Workaround for issue #11210

  default_action {
    target_group_arn = "${var.use_lb_cert ? element(concat(aws_lb_target_group.nomad_https_4646.*.arn, list("")), 0) : element(concat(aws_lb_target_group.nomad_http_4646.*.arn, list("")), 0)}" # TODO: Workaround for issue #11210
    type             = "forward"
  }
}
