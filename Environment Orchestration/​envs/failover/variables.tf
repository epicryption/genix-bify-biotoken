variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "failover"
}

variable "cidr_block" {
  type    = string
  default = "10.40.0.0/16"
}

variable "node_count" {
  type    = number
  default = 0
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"
}
