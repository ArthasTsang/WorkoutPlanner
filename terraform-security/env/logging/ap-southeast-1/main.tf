module "demo_logging" {
  source = "../../../modules/logging"

  providers = {
    aws = aws.demo
  }
  
  env      = "demo"
  project  = var.project
  region   = var.region
}

module "dev_logging" {
  source = "../../../modules/logging"

  providers = {
    aws = aws.dev
  }
  
  env      = "dev"
  project  = var.project
  region   = var.region
}

module "uat_logging" {
  source = "../../../modules/logging"

  providers = {
    aws = aws.uat
  }
  
  env      = "uat"
  project  = var.project
  region   = var.region
}

module "prod_logging" {
  source = "../../../modules/logging"

  providers = {
    aws = aws.prod
  }
  
  env      = "prod"
  project  = var.project
  region   = var.region
}