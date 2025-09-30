output "step_functions_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.main.arn
}

output "step_functions_name" {
  description = "Step Functions state machine name"
  value       = aws_sfn_state_machine.main.name
}

output "eventbridge_rule_arns" {
  description = "Map of EventBridge rule ARNs"
  value = {
    dhis2_ingestion    = aws_cloudwatch_event_rule.dhis2_ingestion.arn
    validation_pipeline = aws_cloudwatch_event_rule.validation_pipeline.arn
  }
}

output "sqs_queue_arns" {
  description = "Map of SQS queue ARNs"
  value = {
    s3_validation      = aws_sqs_queue.s3_validation.arn
    dhis2_puller_dlq   = aws_sqs_queue.dhis2_puller_dlq.arn
    s3_validator_dlq   = aws_sqs_queue.s3_validator_dlq.arn
  }
}

output "sqs_queue_urls" {
  description = "Map of SQS queue URLs"
  value = {
    s3_validation      = aws_sqs_queue.s3_validation.url
    dhis2_puller_dlq   = aws_sqs_queue.dhis2_puller_dlq.url
    s3_validator_dlq   = aws_sqs_queue.s3_validator_dlq.url
  }
}
