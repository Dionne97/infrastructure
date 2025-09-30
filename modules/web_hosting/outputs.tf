output "s3_bucket_name" {
  description = "S3 bucket name for web hosting"
  value       = aws_s3_bucket.web_hosting.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for web hosting"
  value       = aws_s3_bucket.web_hosting.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "cloudfront_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "route53_zone_id" {
  description = "Route53 zone ID (if domain provided)"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].zone_id : null
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN (if domain provided)"
  value       = var.domain_name != "" ? aws_acm_certificate.main[0].arn : null
}
