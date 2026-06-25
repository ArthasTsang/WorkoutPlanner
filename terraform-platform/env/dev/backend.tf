terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-dev-mwp-terraform-ap-east-1"
    key            = "platform/dev/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "dev-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::344626517534:role/mwp-platform-terraform-role"
      session_name = "terraform-backend-session"
    }
  }
}