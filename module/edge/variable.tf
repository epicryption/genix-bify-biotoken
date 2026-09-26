variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC identifier"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public network subnets to host edge load balancers"
}
