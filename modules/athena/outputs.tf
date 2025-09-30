output "workgroup_name" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.validation.name
}

output "workgroup_arn" {
  description = "Athena workgroup ARN"
  value       = aws_athena_workgroup.validation.arn
}

output "results_bucket_name" {
  description = "Athena results bucket name"
  value       = aws_s3_bucket.athena_results.bucket
}

output "named_query_ids" {
  description = "Map of named query IDs"
  value = {
    row_count_raw     = aws_athena_named_query.row_count_raw.id
    row_count_curated = aws_athena_named_query.row_count_curated.id
    schema_validation = aws_athena_named_query.schema_validation.id
  }
}

output "athena_policy_arn" {
  description = "Athena access policy ARN"
  value       = aws_iam_policy.athena_access.arn
}
