output "vpc_id" {
  value = module.network.vpc_id
}

output "eks_endpoint" {
  value = module.compute.cluster_endpoint
}

output "db_endpoint" {
  value = module.database.endpoint
}

output "redis_endpoint" {
  value = module.cache.primary_endpoint_address
}

output "alb_dns_name" {
  value = module.edge.alb_dns_name
}
region            = "eu-west-1"
environment       = "eu-west"
cidr_block        = "10.20.0.0/16"
node_count        = 3
db_instance_class = "db.t4g.medium"
