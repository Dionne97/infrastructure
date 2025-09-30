variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
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

variable "dhis2_base_url" {
  description = "DHIS2 base URL"
  type        = string
  default     = ""
}

variable "dhis2_username" {
  description = "DHIS2 username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "dhis2_password" {
  description = "DHIS2 password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = ""
}
