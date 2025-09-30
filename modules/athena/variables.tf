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
  })
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
