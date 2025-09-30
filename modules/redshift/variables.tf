variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "redshift_role_arn" {
  description = "Redshift role ARN"
  type        = string
}

variable "base_capacity" {
  description = "Base capacity for Redshift Serverless"
  type        = number
  default     = 32
}
