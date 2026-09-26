resource "aws_db_subnet_group" "main" {
  name       = "dbsng-${var.environment}"
  subnet_ids = var.private_data_subnet_ids

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_security_group" "rds" {
  name        = "sg-${var.environment}-rds"
  description = "Allow inbound PostgreSQL access from compute layer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL access from internal compute"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.compute_security_group_id]
  }

  egress {
    description = "Disallow default egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-${var.environment}-rds"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_kms_key" "rds" {
  description             = "KMS Key for RDS Instance Encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "pg-${var.environment}-postgres15"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

resource "aws_db_instance" "primary" {
  identifier                  = "rds-${var.environment}-primary"
  allocated_storage           = 20
  max_allocated_storage       = 100
  engine                      = "postgres"
  engine_version              = "15.4"
  instance_class              = var.db_instance_class
  db_name                     = "bify_db"
  username                    = "bify_admin"
  manage_master_user_password = true
  kms_key_id                  = aws_kms_key.rds.arn
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  parameter_group_name        = aws_db_parameter_group.main.name
  publicly_accessible         = false
  multi_az                    = true
  storage_encrypted           = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "rds-${var.environment}-final-snapshot"

  tags = {
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}
