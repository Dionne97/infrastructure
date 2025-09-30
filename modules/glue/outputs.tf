output "database_names" {
  description = "Map of Glue database names"
  value = {
    raw     = aws_glue_catalog_database.raw.name
    curated = aws_glue_catalog_database.curated.name
    features = aws_glue_catalog_database.features.name
  }
}

output "crawler_names" {
  description = "Map of Glue crawler names"
  value = {
    raw_data     = aws_glue_crawler.raw_data.name
    curated_data = aws_glue_crawler.curated_data.name
    features_data = aws_glue_crawler.features_data.name
  }
}

output "job_names" {
  description = "Map of Glue job names"
  value = {
    harmonize = aws_glue_job.harmonize_data.name
    mfr_joins = aws_glue_job.mfr_joins.name
  }
}

output "connection_name" {
  description = "Glue connection name"
  value       = aws_glue_connection.dhis2.name
}
