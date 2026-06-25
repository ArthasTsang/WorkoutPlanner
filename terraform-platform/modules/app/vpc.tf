data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["*-${var.project}-vpc"]
  }
}

data "aws_subnets" "web_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*web-subnet*"]
  }
}

data "aws_security_group" "alb_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*alb-sg"]
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