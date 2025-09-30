# Remote state configuration
terraform {
  backend "remote" {
    organization = "heal-platform"
    
    workspaces {
      name = "infrastructure"
    }
  }
}
