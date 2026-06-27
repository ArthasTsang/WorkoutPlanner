module "network" {
  source = "../../../modules/vpc"

  providers = {
    aws = aws
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

module "prod_ram_sharing" {
  source = "../../../modules/ram"

  providers = {
    aws = aws
    aws.workload_account = aws.prod_account
  }

  env = var.env
  workload_env = "prod"
  project = var.project
  workload_account = var.prod_account
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