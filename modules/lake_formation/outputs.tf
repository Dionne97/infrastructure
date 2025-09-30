output "data_lake_settings" {
  description = "Lake Formation data lake settings"
  value       = aws_lakeformation_data_lake_settings.main
}

output "resource_arns" {
  description = "Map of Lake Formation resource ARNs"
  value = {
    raw_data     = aws_lakeformation_resource.raw_data.arn
    curated_data = aws_lakeformation_resource.curated_data.arn
    features_data = aws_lakeformation_resource.features_data.arn
  }
}
