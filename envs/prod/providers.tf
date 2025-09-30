# Default AWS provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "heal-mvp"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# AWS provider for us-east-1 (required for ACM certificates and CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "heal-mvp"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
