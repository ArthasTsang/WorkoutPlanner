terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-demo-mwp-terraform-ap-east-1"
    key            = "service/workout/demo/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::334044477312:role/mwp-service-workout-terraform-role"
    }
  }
}