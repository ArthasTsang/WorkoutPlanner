module "service" {
  source = "../../../modules/ecs"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  service  = var.service
  region   = var.region
  is_cost_saving = var.is_cost_saving
}

module "deploy" {
  source = "../../../modules/deploy"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  service  = var.service
  ecs_service_name = module.service.ecs_service_name
  blue_tg_name = module.service.blue_tg_name
  green_tg_name = module.service.green_tg_name
  region   = var.region
  is_cost_saving = var.is_cost_saving
}