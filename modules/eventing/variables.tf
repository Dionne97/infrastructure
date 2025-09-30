variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  type = object({
    dhis2_puller    = string
    s3_validator    = string
    redshift_loader = string
    ml_publisher    = string
  })
}

variable "bucket_names" {
  description = "Map of S3 bucket names"
  type = object({
    raw_data = string
  })
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
}
