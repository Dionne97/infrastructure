# Backend configuration for dev environment
terraform {
  backend "s3" {
    bucket         = "heal-dev-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "heal-dev-terraform-locks"
    encrypt        = true
  }
}
