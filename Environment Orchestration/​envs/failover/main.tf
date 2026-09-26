terraform {
  backend "s3" {}
}

module "network" {
  source       = "../../modules/network"
  region       = var.region
  environment  = var.environment
  cidr_block   = var.cidr_block
  az_count     = 3
  nat_strategy = "single"
}

resource "aws_security_group" "compute_client" {
  name        = "sg-${var.environment}-compute-client"
  description = "Base Security Group for EKS worker nodes"
  vpc_id      = module.network.vpc_id

  egress {
    description = "Allow outbound Internet egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-${var.environment}-compute-client"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

module "compute" {
  source             = "../../modules/compute"
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_compute_subnet_ids
  node_count         = var.node_count
}

module "database" {
  source                    = "../../modules/database"
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  private_data_subnet_ids   = module.network.private_data_subnet_ids
  compute_security_group_id = aws_security_group.compute_client.id
  db_instance_class         = var.db_instance_class
}

module "cache" {
  source                    = "../../modules/cache"
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  private_data_subnet_ids   = module.network.private_data_subnet_ids
  compute_security_group_id = aws_security_group.compute_client.id
}

module "edge" {
  source            = "../../modules/edge"
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}
