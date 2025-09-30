# Networking outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

# S3 bucket outputs
output "s3_bucket_names" {
  description = "S3 bucket names"
  value       = module.storage.bucket_names
}

# KMS key outputs
output "kms_key_arns" {
  description = "KMS key ARNs"
  value       = module.kms.key_arns
}

# Redshift outputs
output "redshift_endpoint" {
  description = "Redshift Serverless endpoint"
  value       = module.redshift.endpoint
  sensitive   = true
}

output "redshift_jdbc_url" {
  description = "Redshift JDBC URL"
  value       = module.redshift.jdbc_url
  sensitive   = true
}

# API Gateway outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}

# Cognito outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.cognito.user_pool_client_id
}

# CloudFront outputs
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.web_hosting.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = module.web_hosting.cloudfront_url
}

# Step Functions outputs
output "step_functions_arn" {
  description = "Step Functions state machine ARN"
  value       = module.eventing.step_functions_arn
}

# Lambda function outputs
output "lambda_function_arns" {
  description = "Lambda function ARNs"
  value       = module.lambda.function_arns
}

# Secrets Manager outputs
output "secrets_manager_arns" {
  description = "Secrets Manager secret ARNs"
  value       = module.iam_secrets.secret_arns
  sensitive   = true
}

# Monitoring outputs
output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

# QuickSight outputs (if enabled)
output "quicksight_dashboard_url" {
  description = "QuickSight dashboard URL"
  value       = var.enable_quicksight ? module.quicksight.dashboard_url : null
}
