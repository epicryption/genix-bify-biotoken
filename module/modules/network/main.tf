data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-${var.environment}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "igw-${var.environment}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                                      = "subnet-${var.environment}-public-${local.selected_azs[count.index]}"
    Environment                               = var.environment
    ManagedBy                                 = "OpenTofu"
    "kubernetes.io/role/elb"                  = "1"
  }
}

resource "aws_subnet" "private_compute" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 4)
  availability_zone = local.selected_azs[count.index]

  tags = {
    Name                                      = "subnet-${var.environment}-private-compute-${local.selected_azs[count.index]}"
    Environment                               = var.environment
    ManagedBy                                 = "OpenTofu"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

resource "aws_subnet" "private_data" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 8)
  availability_zone = local.selected_azs[count.index]

  tags = {
    Name        = "subnet-${var.environment}-private-data-${local.selected_azs[count.index]}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_eip" "nat" {
  count  = var.nat_strategy == "per-az" ? var.az_count : 1
  domain = "vpc"

  tags = {
    Name        = "eip-${var.environment}-${count.index}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.nat_strategy == "per-az" ? var.az_count : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "nat-${var.environment}-${count.index}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "rt-${var.environment}-public"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_strategy == "per-az" ? aws_nat_gateway.nat[count.index].id : aws_nat_gateway.nat[0].id
  }

  tags = {
    Name        = "rt-${var.environment}-private-${local.selected_azs[count.index]}"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_compute" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_compute[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private_data" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
