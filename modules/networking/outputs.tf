output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "vpc_endpoint_ids" {
  description = "VPC Endpoint IDs"
  value = {
    s3             = aws_vpc_endpoint.s3.id
    sts            = aws_vpc_endpoint.sts.id
    secrets_manager = aws_vpc_endpoint.secrets_manager.id
    cloudwatch_logs = aws_vpc_endpoint.cloudwatch_logs.id
    athena         = aws_vpc_endpoint.athena.id
    glue           = aws_vpc_endpoint.glue.id
    redshift       = aws_vpc_endpoint.redshift.id
    sagemaker      = aws_vpc_endpoint.sagemaker.id
  }
}
