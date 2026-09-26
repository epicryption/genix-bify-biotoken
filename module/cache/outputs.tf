output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.main.configuration_endpoint_address
}
