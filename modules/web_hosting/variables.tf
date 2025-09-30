variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "web_bucket_name" {
  description = "S3 bucket name for web hosting"
  type        = string
}
