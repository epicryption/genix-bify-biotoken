variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC identifier"
}

variable "private_data_subnet_ids" {
  type        = list(string)
  description = "Subnet scope for ElastiCache network isolation"
}

variable "compute_security_group_id" {
  type        = string
  description = "Security group identifier of compute nodes"
}
