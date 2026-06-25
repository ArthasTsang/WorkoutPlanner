terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-prod-mwp-terraform-ap-east-1"
    key            = "platform/prod/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "prod-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::136609826199:role/mwp-platform-terraform-role"
      session_name = "terraform-backend-session"
    }
  }
}