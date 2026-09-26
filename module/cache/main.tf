resource "aws_elasticache_subnet_group" "main" {
  name       = "redis-sng-${var.environment}"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "sg-${var.environment}-redis"
  description = "Allow inbound Redis traffic from compute layer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis access from internal compute"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.compute_security_group_id]
  }

  egress {
    description = "Default restrictive egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-${var.environment}-redis"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id        = "redis-${var.environment}"
  description                 = "Redis Cluster Mode Enabled Deployment"
  node_type                   = "cache.t4g.micro"
  port                        = 6379
  parameter_group_name        = "default.redis7.cluster.on"
  subnet_group_name           = aws_elasticache_subnet_group.main.name
  security_group_ids          = [aws_security_group.redis.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled  = true

  num_node_groups         = 2
  replicas_per_node_group = 1

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}
