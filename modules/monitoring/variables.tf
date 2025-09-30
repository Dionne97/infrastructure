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
    raw_data = string
  })
}

variable "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  type = object({
    dhis2_puller    = string
    s3_validator    = string
    redshift_loader = string
    ml_publisher    = string
    quicksight_embed = string
    dashboard_api   = string
  })
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "redshift_workgroup_name" {
  description = "Redshift workgroup name"
  type        = string
}

variable "step_functions_arn" {
  description = "Step Functions state machine ARN"
  type        = string
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = ""
}
