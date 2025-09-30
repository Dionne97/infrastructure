locals {
  # Common naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  
  # Availability zones
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  
  # S3 bucket names
  bucket_names = {
    raw_data      = "${local.name_prefix}-raw"
    curated_data  = "${local.name_prefix}-curated"
    features_data = "${local.name_prefix}-features"
    quarantine    = "${local.name_prefix}-quarantine"
    logs          = "${local.name_prefix}-logs"
    web_hosting   = "${local.name_prefix}-web"
    terraform_state = "${local.name_prefix}-terraform-state"
  }
  
  # KMS key aliases
  kms_aliases = {
    s3_data    = "alias/${local.name_prefix}-s3-data"
    redshift   = "alias/${local.name_prefix}-redshift"
    glue       = "alias/${local.name_prefix}-glue"
    logs       = "alias/${local.name_prefix}-logs"
    secrets    = "alias/${local.name_prefix}-secrets"
  }
}
