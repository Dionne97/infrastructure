output "key_arns" {
  description = "Map of KMS key ARNs"
  value = {
    s3_data  = aws_kms_key.s3_data.arn
    redshift = aws_kms_key.redshift.arn
    glue     = aws_kms_key.glue.arn
    logs     = aws_kms_key.logs.arn
    secrets  = aws_kms_key.secrets.arn
  }
}

output "key_ids" {
  description = "Map of KMS key IDs"
  value = {
    s3_data  = aws_kms_key.s3_data.key_id
    redshift = aws_kms_key.redshift.key_id
    glue     = aws_kms_key.glue.key_id
    logs     = aws_kms_key.logs.key_id
    secrets  = aws_kms_key.secrets.key_id
  }
}
