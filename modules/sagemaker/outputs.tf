output "notebook_instance_name" {
  description = "SageMaker notebook instance name"
  value       = aws_sagemaker_notebook_instance.main.name
}

output "notebook_instance_url" {
  description = "SageMaker notebook instance URL"
  value       = aws_sagemaker_notebook_instance.main.url
}

output "model_package_group_name" {
  description = "SageMaker model package group name"
  value       = aws_sagemaker_model_package_group.main.model_package_group_name
}

output "model_name" {
  description = "SageMaker model name"
  value       = aws_sagemaker_model.main.name
}

output "endpoint_name" {
  description = "SageMaker endpoint name"
  value       = aws_sagemaker_endpoint.main.name
}

output "endpoint_url" {
  description = "SageMaker endpoint URL"
  value       = aws_sagemaker_endpoint.main.url
}
