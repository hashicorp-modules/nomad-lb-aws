variable "create"            { }
variable "ami_owner"         { default = "309956199498" } # Base RHEL owner
variable "ami_name"          { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name
variable "name"              { }
variable "vpc_cidrs_public"  { type = "list" }
variable "vpc_cidrs_private" { type = "list" }
variable "nat_count"         { }
variable "bastion_count"     { }
variable "is_internal_lb"    { }
variable "use_lb_cert"       { }
variable "lb_ssl_policy"     { }
variable "tags"              { type = "map" }
