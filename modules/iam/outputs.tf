output "lambda_role_arns" {
  description = "Map of Lambda role ARNs"
  value = {
    execution = aws_iam_role.lambda_execution.arn
    ingest    = aws_iam_role.lambda_ingest.arn
    validator = aws_iam_role.lambda_validator.arn
    api       = aws_iam_role.lambda_api.arn
  }
}

output "glue_role_arn" {
  description = "Glue job role ARN"
  value       = aws_iam_role.glue_job.arn
}

output "glue_crawler_role_arn" {
  description = "Glue crawler role ARN"
  value       = aws_iam_role.glue_crawler.arn
}

output "redshift_role_arn" {
  description = "Redshift role ARN"
  value       = aws_iam_role.redshift.arn
}

output "sagemaker_role_arn" {
  description = "SageMaker role ARN"
  value       = aws_iam_role.sagemaker.arn
}

output "quicksight_role_arn" {
  description = "QuickSight role ARN"
  value       = aws_iam_role.quicksight.arn
}

output "secret_arns" {
  description = "Map of Secrets Manager secret ARNs"
  value = {
    dhis2_credentials = aws_secretsmanager_secret.dhis2_credentials.arn
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = aws_sns_topic.notifications.arn
}
