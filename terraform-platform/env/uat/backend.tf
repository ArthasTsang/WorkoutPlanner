terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-uat-mwp-terraform-ap-east-1"
    key            = "platform/uat/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "uat-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::619924817113:role/mwp-platform-terraform-role"
      session_name = "terraform-backend-session"
    }
  }
}