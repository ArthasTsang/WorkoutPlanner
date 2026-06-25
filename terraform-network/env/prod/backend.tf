terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-mwp-terraform-ap-east-1"
    key            = "network/prod/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "network-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::977399288390:role/mwp-network-terraform-role"
      session_name = "terraform-backend-session"
    }
  }
}