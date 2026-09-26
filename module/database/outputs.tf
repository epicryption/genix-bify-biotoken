output "endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}
