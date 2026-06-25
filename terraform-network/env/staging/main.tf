module "network" {
  source = "../../modules/vpc"

  providers = {
    aws = aws
    aws.us_east_1 = aws.us_east_1
  }
  
  env      = var.env
  project  = var.project
  region   = var.region
  vpc_cidr = var.vpc_cidr
  requested_az_count = var.requested_az_count
  is_cost_saving = var.is_cost_saving
}

locals {
  web_subnet_ids = [for s in module.network.web_subnet : s.id]
  web_subnet_arns = [for s in module.network.web_subnet : s.arn]
  app_subnet_ids = [for s in module.network.app_subnet : s.id]
  app_subnet_arns = [for s in module.network.app_subnet : s.arn]
  db_subnet_ids = [for s in module.network.db_subnet : s.id]
  db_subnet_arns = [for s in module.network.db_subnet : s.arn]
}

module "demo_ram_sharing" {
  source = "../../modules/ram"

  providers = {
    aws = aws
    aws.us_east_1 = aws.us_east_1
    aws.workload_account = aws.demo_account
  }

  env = var.env
  workload_env = "demo"
  project = var.project
  workload_account = var.demo_account
  vpc_id = module.network.vpc.id
  web_subnet_ids = local.web_subnet_ids
  web_subnet_arns = local.web_subnet_arns
  app_subnet_ids = local.app_subnet_ids
  app_subnet_arns = local.app_subnet_arns
  db_subnet_ids = local.db_subnet_ids
  db_subnet_arns = local.db_subnet_arns
  alb_sg_id = module.network.alb_sg.id
  alb_sg_arn = module.network.alb_sg.arn
  app_sg_id = module.network.app_sg.id
  app_sg_arn = module.network.app_sg.arn
}

module "dev_ram_sharing" {
  source = "../../modules/ram"

  providers = {
    aws = aws
    aws.us_east_1 = aws.us_east_1
    aws.workload_account = aws.dev_account
  }

  env = var.env
  workload_env = "dev"
  project = var.project
  workload_account = var.dev_account
  vpc_id = module.network.vpc.id
  web_subnet_ids = local.web_subnet_ids
  web_subnet_arns = local.web_subnet_arns
  app_subnet_ids = local.app_subnet_ids
  app_subnet_arns = local.app_subnet_arns
  db_subnet_ids = local.db_subnet_ids
  db_subnet_arns = local.db_subnet_arns
  alb_sg_id = module.network.alb_sg.id
  alb_sg_arn = module.network.alb_sg.arn
  app_sg_id = module.network.app_sg.id
  app_sg_arn = module.network.app_sg.arn
}

module "uat_ram_sharing" {
  source = "../../modules/ram"

  providers = {
    aws = aws
    aws.us_east_1 = aws.us_east_1
    aws.workload_account = aws.uat_account
  }

  env = var.env
  workload_env = "uat"
  project = var.project
  workload_account = var.uat_account
  vpc_id = module.network.vpc.id
  web_subnet_ids = local.web_subnet_ids
  web_subnet_arns = local.web_subnet_arns
  app_subnet_ids = local.app_subnet_ids
  app_subnet_arns = local.app_subnet_arns
  db_subnet_ids = local.db_subnet_ids
  db_subnet_arns = local.db_subnet_arns
  alb_sg_id = module.network.alb_sg.id
  alb_sg_arn = module.network.alb_sg.arn
  app_sg_id = module.network.app_sg.id
  app_sg_arn = module.network.app_sg.arn
}