create            = true
name              = "nomad-lb-adv"
vpc_cidrs_public  = ["10.139.1.0/24", "10.139.2.0/24",]
vpc_cidrs_private = ["10.139.11.0/24", "10.139.12.0/24",]
nat_count         = "1"
bastion_count     = "0"
is_internal_lb    = true
use_lb_cert       = true
lb_ssl_policy     = "ELBSecurityPolicy-2016-08"
lb_logs_prefix    = "nomad"
lb_logs_enabled   = true
tags              = { "foo" = "bar", "fizz" = "buzz" }
