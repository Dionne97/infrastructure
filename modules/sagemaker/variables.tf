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
    curated_data = string
    features_data = string
  })
}

variable "sagemaker_role_arn" {
  description = "SageMaker execution role ARN"
  type        = string
}
