module "firehose" {
  source = "../../../modules/firehose"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  region   = var.region
  source_account_ids = var.source_account_ids
}