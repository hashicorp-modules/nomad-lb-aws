variable "ami_owner" { default = "309956199498" } # Base RHEL owner
variable "ami_name"  { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name

variable "name" {
  default = "nomad-lb-simple"
}

variable "vpc_cidrs_public"  {
  type    = "list"
  default = ["10.139.1.0/24", "10.139.2.0/24", "10.139.3.0/24",]
}

variable "vpc_cidrs_private" {
  type    = "list"
  default = ["10.139.11.0/24", "10.139.12.0/24", "10.139.13.0/24",]
}

variable "nat_count"     { default = "1" }
variable "bastion_count" { default = "0" }

variable "tags" {
  type        = "map"
  default     = {}
}
