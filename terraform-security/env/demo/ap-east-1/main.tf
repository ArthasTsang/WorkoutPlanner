module "platform" {
  source = "../../../modules/platform"

  providers = {
    aws = aws
  }
  
  log_account_id = var.log_account_id
  env      = var.env
  project  = var.project
  service  = var.service
  region   = var.region
}

module "workout" {
  source = "../../../modules/service_workout"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  service  = var.service
  region   = var.region
}