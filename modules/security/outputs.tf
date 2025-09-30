output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    redshift   = aws_security_group.redshift.id
    lambda     = aws_security_group.lambda.id
    sagemaker  = aws_security_group.sagemaker.id
    quicksight = aws_security_group.quicksight.id
    alb        = aws_security_group.alb.id
  }
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.main.arn
}

output "config_recorder_arn" {
  description = "AWS Config recorder ARN"
  value       = aws_config_configuration_recorder.main.arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}
