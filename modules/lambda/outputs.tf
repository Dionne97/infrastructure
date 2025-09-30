output "function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    dhis2_puller    = aws_lambda_function.dhis2_puller.arn
    s3_validator    = aws_lambda_function.s3_validator.arn
    redshift_loader = aws_lambda_function.redshift_loader.arn
    ml_publisher    = aws_lambda_function.ml_publisher.arn
    quicksight_embed = aws_lambda_function.quicksight_embed.arn
    dashboard_api   = aws_lambda_function.dashboard_api.arn
  }
}

output "function_names" {
  description = "Map of Lambda function names"
  value = {
    dhis2_puller    = aws_lambda_function.dhis2_puller.function_name
    s3_validator    = aws_lambda_function.s3_validator.function_name
    redshift_loader = aws_lambda_function.redshift_loader.function_name
    ml_publisher    = aws_lambda_function.ml_publisher.function_name
    quicksight_embed = aws_lambda_function.quicksight_embed.function_name
    dashboard_api   = aws_lambda_function.dashboard_api.function_name
  }
}

output "security_group_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda.id
}
