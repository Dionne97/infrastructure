output "data_source_id" {
  description = "QuickSight data source ID"
  value       = aws_quicksight_data_source.redshift.data_source_id
}

output "data_set_id" {
  description = "QuickSight dataset ID"
  value       = aws_quicksight_data_set.harmonized_data.data_set_id
}

output "analysis_id" {
  description = "QuickSight analysis ID"
  value       = aws_quicksight_analysis.main.analysis_id
}

output "dashboard_id" {
  description = "QuickSight dashboard ID"
  value       = aws_quicksight_dashboard.main.dashboard_id
}

output "dashboard_url" {
  description = "QuickSight dashboard URL"
  value       = "https://${data.aws_region.current.name}.quicksight.aws.amazon.com/sn/dashboards/${aws_quicksight_dashboard.main.dashboard_id}"
}

output "embed_user_name" {
  description = "QuickSight embed user name"
  value       = aws_quicksight_user.embed_user.user_name
}

# Data source
data "aws_region" "current" {}
