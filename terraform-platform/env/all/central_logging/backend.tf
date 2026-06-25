terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-log-mwp-terraform-ap-east-1"
    key            = "platform/central_logging/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "log-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::280793169284:role/mwp-platform-terraform-role"
      session_name = "terraform-backend-session"
    }
  }
}