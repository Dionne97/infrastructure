# Backend configuration for prod environment
terraform {
  backend "s3" {
    bucket         = "heal-prod-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "heal-prod-terraform-locks"
    encrypt        = true
  }
}
