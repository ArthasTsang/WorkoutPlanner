module "demo_firehose" {
  source = "../../../modules/firehose"

  providers = {
    aws = aws.demo
  }
  
  env      = "demo"
  project  = var.project
  region   = var.region
  source_account_ids = [var.demo_account_id]
}

module "dev_firehose" {
  source = "../../../modules/firehose"

  providers = {
    aws = aws.dev
  }
  
  env      = "dev"
  project  = var.project
  region   = var.region
  source_account_ids = [var.dev_account_id]
}

module "uat_firehose" {
  source = "../../../modules/firehose"

  providers = {
    aws = aws.uat
  }
  
  env      = "uat"
  project  = var.project
  region   = var.region
  source_account_ids = [var.uat_account_id]
}

module "prod_firehose" {
  source = "../../../modules/firehose"

  providers = {
    aws = aws.prod
  }
  
  env      = "prod"
  project  = var.project
  region   = var.region
  source_account_ids = [var.prod_account_id]
}