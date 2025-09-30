variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "bucket_names" {
  description = "Map of S3 bucket names"
  type = object({
    raw_data     = string
    curated_data = string
    features_data = string
    quarantine   = string
  })
}

variable "kms_key_arns" {
  description = "Map of KMS key ARNs"
  type = object({
    s3_data  = string
    redshift = string
    glue     = string
    logs     = string
    secrets  = string
  })
}

variable "lambda_role_arns" {
  description = "Map of Lambda role ARNs"
  type = object({
    execution = string
    ingest    = string
    validator = string
    api       = string
  })
}

variable "redshift_endpoint" {
  description = "Redshift Serverless endpoint"
  type        = string
}

variable "secrets_manager_arn" {
  description = "Secrets Manager ARN for DHIS2 credentials"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}
