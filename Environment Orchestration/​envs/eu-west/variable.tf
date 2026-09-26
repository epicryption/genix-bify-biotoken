variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "environment" {
  type    = string
  default = "eu-west"
}

variable "cidr_block" {
  type    = string
  default = "10.20.0.0/16"
}

variable "node_count" {
  type    = number
  default = 3
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"
}
