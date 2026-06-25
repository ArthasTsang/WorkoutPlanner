module "docdb" {
  source = "../../modules/docdb"

  providers = {
    aws = aws
  }

  env      = var.env
  project  = var.project
  region   = var.region
  network_account_id = var.network_account_id
  db_name  = var.db_name
  requested_db_instance_count = var.requested_db_instance_count
}

module "scheduler" {
  source = "../../modules/scheduler"

  providers = {
    aws = aws
  }

  env      = var.env
  project  = var.project
  region   = var.region
  docdb_cluster_arn = module.docdb.docdb.arn
  docdb_cluster_id = module.docdb.docdb.cluster_identifier
  is_startup_required = false
}

module "app" {
  source = "../../modules/app"

  providers = {
    aws = aws
  }
  
  env      = var.env
  project  = var.project
  region   = var.region
  docdb_cluster_arn = module.docdb.docdb.arn
  is_cost_saving = var.is_cost_saving
}

# module "edge" {
#   source = "../../modules/edge"

#   providers = {
#     aws = aws
#     aws.us_east_1 = aws.us_east_1
#   }
  
#   env      = var.env
#   project  = var.project
#   region   = var.region
#   is_alt_domain = var.is_alt_domain
#   alt_domain_name = var.alt_domain_name
#   domain_cert_arn = var.domain_cert_arn
#   # No ALB created under cost saving
#   alb_dns_name = var.is_cost_saving ? "" : module.app.alb_dns_name[0]
#   is_cost_saving = var.is_cost_saving
# }

# module "cognito" {
#   source = "../../modules/cognito"

#   providers = {
#     aws = aws
#   }

#   env      = var.env
#   project  = var.project
#   region   = var.region
#   cloudfront_distribution_domain_name = module.edge.cloudfront_distribution_domain_name
# }

module "logging" {
  source = "../../modules/logging"

  providers = {
    aws = aws
  }

  env      = var.env
  project  = var.project
  region   = var.region
  log_account_id = var.log_account_id
}