output "namespace_name" {
  description = "Redshift Serverless namespace name"
  value       = aws_redshiftserverless_namespace.main.namespace_name
}

output "workgroup_name" {
  description = "Redshift Serverless workgroup name"
  value       = aws_redshiftserverless_workgroup.main.workgroup_name
}

output "endpoint" {
  description = "Redshift Serverless endpoint"
  value       = aws_redshiftserverless_workgroup.main.endpoint[0].address
  sensitive   = true
}

output "port" {
  description = "Redshift Serverless port"
  value       = aws_redshiftserverless_workgroup.main.endpoint[0].port
}

output "jdbc_url" {
  description = "Redshift JDBC URL"
  value       = "jdbc:redshift://${aws_redshiftserverless_workgroup.main.endpoint[0].address}:${aws_redshiftserverless_workgroup.main.endpoint[0].port}/${aws_redshiftserverless_namespace.main.db_name}"
  sensitive   = true
}

output "credentials_secret_arn" {
  description = "Redshift credentials secret ARN"
  value       = aws_secretsmanager_secret.redshift_credentials.arn
  sensitive   = true
}

output "security_group_id" {
  description = "Redshift security group ID"
  value       = aws_security_group.redshift.id
}
