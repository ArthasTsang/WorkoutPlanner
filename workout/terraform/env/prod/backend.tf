terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-prod-mwp-terraform-ap-east-1"
    key            = "service/workout/prod/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "prod-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::136609826199:role/mwp-service-workout-terraform-role"
    }
  }
}