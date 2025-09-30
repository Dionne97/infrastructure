output "bucket_names" {
  description = "Map of S3 bucket names"
  value = {
    raw_data     = aws_s3_bucket.raw_data.bucket
    curated_data = aws_s3_bucket.curated_data.bucket
    features_data = aws_s3_bucket.features_data.bucket
    quarantine   = aws_s3_bucket.quarantine.bucket
    logs         = aws_s3_bucket.logs.bucket
    web_hosting  = aws_s3_bucket.web_hosting.bucket
  }
}

output "bucket_arns" {
  description = "Map of S3 bucket ARNs"
  value = {
    raw_data     = aws_s3_bucket.raw_data.arn
    curated_data = aws_s3_bucket.curated_data.arn
    features_data = aws_s3_bucket.features_data.arn
    quarantine   = aws_s3_bucket.quarantine.arn
    logs         = aws_s3_bucket.logs.arn
    web_hosting  = aws_s3_bucket.web_hosting.arn
  }
}
