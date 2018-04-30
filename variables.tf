variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "name" {
  description = "Name for resources, defaults to \"nomad-lb-aws\"."
  default     = "nomad-aws"
}

variable "vpc_id" {
  description = "VPC ID to provision LB in."
}

variable "cidr_blocks" {
  description = "CIDR blocks to provision LB across."
  type        = "list"
}

variable "subnet_ids" {
  description = "Subnet ID(s) to provision LB across."
  type        = "list"
}

variable "is_internal_lb" {
  description = "Is an internal load balancer, defaults to true."
  default     = true
}

variable "use_lb_cert" {
  description = "Use certificate passed in for the LB IAM listener, \"lb_cert\" and \"lb_private_key\" must be passed in if true, defaults to false."
  default     = false
}

variable "lb_cert" {
  description = "Certificate for LB IAM server certificate."
  default     = ""
}

variable "lb_private_key" {
  description = "Private key for LB IAM server certificate."
  default     = ""
}

variable "lb_cert_chain" {
  description = "Certificate chain for LB IAM server certificate."
  default     = ""
}

variable "lb_ssl_policy" {
  description = "SSL policy for LB, defaults to \"ELBSecurityPolicy-2016-08\"."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "lb_bucket" {
  description = "S3 bucket override for LB access logs, `lb_bucket_override` be set to true if overriding"
  default     = ""
}

variable "lb_bucket_override" {
  description = "Override the default S3 bucket created for access logs with `lb_bucket`, defaults to false."
  default     = false
}

variable "lb_bucket_prefix" {
  description = "S3 bucket prefix for LB access logs."
  default     = ""
}

variable "lb_logs_enabled" {
  description = "S3 bucket LB access logs enabled, defaults to true."
  default     = true
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = "map"
  default     = {}
}
