# Remote state configuration
terraform {
    backend "remote" {
    organization = "heal-platform"
    
    workspaces {
      name = "infrastructure"
    }
  }
  backend "s3" {
    # These will be set via terraform init -backend-config
    # bucket         = "heal-terraform-state-<env>"
    # key            = "infrastructure/terraform.tfstate"
    # region         = "us-west-2"
    # dynamodb_table = "heal-terraform-locks"
    # encrypt        = true
  }
}
