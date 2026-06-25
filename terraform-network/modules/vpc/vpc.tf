# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { 
    Name = "${local.name_prefix}-vpc" 
  }
}

# Default route table
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  // remove all routes to prevent any trafiic
  route = []

  tags = {
    Name = "${local.name_prefix}-default-rt"
  }
}

# Web subnets
resource "aws_subnet" "web_subnet" {
  count             = local.final_az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index * 4)
  availability_zone       = local.all_azs[count.index]
  map_public_ip_on_launch = true

  tags = { 
    Name = "${local.name_prefix}-web-subnet-${count.index + 1}" 
  }
}

# App subnets
resource "aws_subnet" "app_subnet" {
  count             = local.final_az_count
  vpc_id            = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index * 4 + 1)
  availability_zone       = local.all_azs[count.index]

  tags = { 
    Name = "${local.name_prefix}-app-subnet-${count.index + 1}" 
  }
}

locals {
  all_app_subnets = [for subnet in aws_subnet.app_subnet : subnet.id]
}

# DB subnets
resource "aws_subnet" "db_subnet" {
  count             = local.final_az_count
  vpc_id            = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index * 4 + 2)
  availability_zone       = local.all_azs[count.index]

  tags = { 
    Name = "${local.name_prefix}-db-subnet-${count.index + 1}" 
  }
}

# Web route tables
resource "aws_route_table" "web_rt" {
  count             = local.final_az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { 
    Name = "${local.name_prefix}-web-rt-${count.index + 1}" 
  }
}

resource "aws_route_table_association" "web_rt_association" {
  count = local.final_az_count
  subnet_id      = aws_subnet.web_subnet[count.index].id
  route_table_id = aws_route_table.web_rt[count.index].id
}

# App route tables
resource "aws_route_table" "app_rt" {
  count = var.is_cost_saving ? 0 : local.final_az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[min(count.index, local.final_nat_count - 1)].id
  }

  tags = { 
    Name = "${local.name_prefix}-app-rt-${count.index + 1}" 
  }
}

resource "aws_route_table_association" "app_rt_association" {
  count = var.is_cost_saving ? 0 : local.final_az_count
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_rt[count.index].id
}

# DB route tables
resource "aws_route_table" "db_rt" {
  count = var.is_cost_saving ? 0 : local.final_az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[min(count.index, local.final_nat_count - 1)].id
  }

  tags = { 
    Name = "${local.name_prefix}-db-rt-${count.index + 1}" 
  }
}

resource "aws_route_table_association" "db_rt_association" {
  count = var.is_cost_saving ? 0 : local.final_az_count
  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_rt[count.index].id
}