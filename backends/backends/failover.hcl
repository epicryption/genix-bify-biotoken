bucket         = "bify-tfstate-prod"
key            = "failover/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "bify-tflock"
encrypt        = true
