module "network" {
  source = "../../../modules/network"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  service  = var.service
  region   = var.region
}