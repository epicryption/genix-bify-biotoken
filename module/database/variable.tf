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
  description = "Subnet scope for database subnet placement"
}

variable "compute_security_group_id" {
  type        = string
  description = "Security group of ingress compute clients"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t4g.medium"
  description = "RDS instance computing class"
}
