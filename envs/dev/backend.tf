# Backend configuration for dev environment
terraform {
  backend "remote" {
    organization = "heal-platform"
    
    workspaces {
      name = "infrastructure-dev"
    }
  }
}
