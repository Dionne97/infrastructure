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
  description = "Map of bucket names"
  type = object({
    raw_data     = string
    curated_data = string
    features_data = string
    quarantine   = string
    logs         = string
    web_hosting  = string
  })
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
