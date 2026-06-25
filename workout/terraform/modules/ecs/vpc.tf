data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["*-${var.project}-vpc"]
  }
}

data "aws_subnets" "app_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*app-subnet*"]
  }
}

data "aws_security_group" "app_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*app-sg"]
  }
}