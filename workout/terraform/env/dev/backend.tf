terraform {
  backend "s3" {
    region         = "ap-east-1"
    bucket         = "twyat-dev-mwp-terraform-ap-east-1"
    key            = "service/workout/dev/terraform.tfstate"
    use_lockfile   = true 
    encrypt        = true

    profile = "dev-arthas"
    assume_role = {
      role_arn     = "arn:aws:iam::344626517534:role/mwp-service-workout-terraform-role"
    }
  }
}