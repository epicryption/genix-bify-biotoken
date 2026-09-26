variable "environment" {
  type        = string
  description = "Target deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC identifier"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for node placement"
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Target worker node scaling capacity"
}
