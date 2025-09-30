variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "redshift_endpoint" {
  description = "Redshift Serverless endpoint"
  type        = string
}

variable "quicksight_role_arn" {
  description = "QuickSight access role ARN"
  type        = string
}
