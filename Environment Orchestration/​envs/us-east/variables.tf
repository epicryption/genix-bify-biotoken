variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "us-east"
}

variable "cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "node_count" {
  type    = number
  default = 3
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"
}
