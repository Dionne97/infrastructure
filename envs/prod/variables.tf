variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "heal"
}

variable "domain_name" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for admin access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production
}

variable "dhis2_base_url" {
  description = "DHIS2 base URL for data ingestion"
  type        = string
  default     = ""
}

variable "dhis2_username" {
  description = "DHIS2 username for API access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "dhis2_password" {
  description = "DHIS2 password for API access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "notification_email" {
  description = "Email address for notifications and alerts"
  type        = string
  default     = ""
}

variable "enable_quicksight" {
  description = "Enable QuickSight resources (requires manual subscription)"
  type        = bool
  default     = false
}

variable "enable_sagemaker" {
  description = "Enable SageMaker resources"
  type        = bool
  default     = true
}

variable "redshift_base_capacity" {
  description = "Base capacity for Redshift Serverless"
  type        = number
  default     = 32
}

variable "enable_lake_formation" {
  description = "Enable Lake Formation for fine-grained permissions"
  type        = bool
  default     = true
}
