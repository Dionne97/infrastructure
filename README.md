# HEAL MVP Infrastructure

This repository contains the Terraform infrastructure for the HEAL MVP (Health Equity Analytics and Learning) project on AWS.

## Architecture Overview

The infrastructure implements a comprehensive data pipeline for health data analytics:

- **Data Ingestion**: DHIS2 API integration via Lambda
- **Data Validation**: S3-based validation pipeline
- **Data Processing**: AWS Glue for ETL and harmonization
- **Data Warehouse**: Redshift Serverless for analytics
- **ML Pipeline**: SageMaker for machine learning
- **BI Dashboard**: QuickSight for business intelligence
- **Web Application**: React app hosted on S3 + CloudFront
- **Security**: Cognito authentication, KMS encryption, VPC isolation

## Project Structure

```
infrastructure/
├── modules/                    # Terraform modules
│   ├── networking/            # VPC, subnets, endpoints
│   ├── iam/                   # IAM roles, policies, secrets
│   ├── kms/                   # KMS keys for encryption
│   ├── s3/                    # S3 buckets for data lake
│   ├── glue/                  # Glue catalog, crawlers, jobs
│   ├── redshift/              # Redshift Serverless
│   ├── athena/                # Athena workgroups
│   ├── lake_formation/        # Lake Formation permissions
│   ├── lambda/                # Lambda functions
│   ├── api_gateway/           # API Gateway
│   ├── cognito/               # Cognito authentication
│   ├── eventing/              # EventBridge, Step Functions, SQS
│   ├── sagemaker/             # SageMaker ML
│   ├── quicksight/            # QuickSight BI
│   ├── web_hosting/           # S3 + CloudFront
│   ├── monitoring/            # CloudWatch, alarms, budgets
│   └── security/              # Security groups, guardrails
├── envs/                      # Environment configurations
│   ├── dev/                   # Development environment
│   └── prod/                  # Production environment
├── main.tf                    # Main Terraform configuration
├── providers.tf               # Provider configurations
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── locals.tf                  # Local values
├── versions.tf                # Version constraints
└── backend.tf                 # Backend configuration
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.5
3. **AWS Account** with necessary permissions
4. **S3 bucket** for Terraform state (create manually)
5. **DynamoDB table** for state locking (create manually)

## Bootstrap Steps

### 1. Create State Bucket and DynamoDB Table

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://heal-dev-terraform-state --region us-west-2
aws s3 mb s3://heal-prod-terraform-state --region us-west-2

# Enable versioning
aws s3api put-bucket-versioning --bucket heal-dev-terraform-state --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket heal-prod-terraform-state --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name heal-dev-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-west-2

aws dynamodb create-table \
  --table-name heal-prod-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-west-2
```

### 2. Initialize Terraform

```bash
# Navigate to environment directory
cd envs/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the infrastructure
terraform apply
```

## Apply Order

The infrastructure is designed to be applied in stages to avoid circular dependencies:

1. **Bootstrap** (state, providers)
2. **KMS/IAM/Secrets** (foundation)
3. **Networking & S3** (core infrastructure)
4. **Glue/Lake Formation/Athena** (data catalog)
5. **Redshift Serverless** (data warehouse)
6. **Lambdas + API Gateway + Cognito** (application layer)
7. **EventBridge + Step Functions + SQS** (orchestration)
8. **SageMaker scaffolding** (ML infrastructure)
9. **QuickSight permissions/DS/embedding** (BI)
10. **Web hosting** (S3+CloudFront+ACM+Route53)
11. **Monitoring/WAF/Guardrails** (observability)

## Configuration

### Environment Variables

Each environment has its own `terraform.tfvars` file:

- `envs/dev/terraform.tfvars` - Development configuration
- `envs/prod/terraform.tfvars` - Production configuration

### Key Configuration Options

- `aws_region`: AWS region for resources
- `environment`: Environment name (dev, prod)
- `domain_name`: Domain name for the application
- `dhis2_base_url`: DHIS2 API endpoint
- `enable_quicksight`: Enable QuickSight resources
- `enable_sagemaker`: Enable SageMaker resources
- `redshift_base_capacity`: Redshift Serverless base capacity

## Security Features

- **VPC Isolation**: Private subnets for data processing
- **KMS Encryption**: All data encrypted at rest
- **IAM Least Privilege**: Minimal required permissions
- **Cognito Authentication**: User authentication and authorization
- **WAF Protection**: Web application firewall
- **GuardDuty**: Threat detection
- **CloudTrail**: Audit logging
- **AWS Config**: Compliance monitoring

## Monitoring and Alerting

- **CloudWatch Alarms**: Lambda errors, API Gateway 5xx, Redshift concurrency
- **SNS Notifications**: Email alerts for critical issues
- **Cost Monitoring**: Budgets and anomaly detection
- **Custom Dashboards**: Operational visibility

## Data Pipeline

1. **Ingestion**: DHIS2 API → Lambda → S3 (raw)
2. **Validation**: S3 events → SQS → Lambda → S3 (curated/quarantine)
3. **Processing**: Glue jobs → S3 (curated)
4. **Warehousing**: Lambda → Redshift Serverless
5. **ML**: SageMaker → S3 (features)
6. **BI**: QuickSight → Redshift/Athena

## Troubleshooting

### Common Issues

1. **State Lock**: If Terraform is stuck, check DynamoDB table
2. **Permissions**: Ensure AWS credentials have sufficient permissions
3. **Resource Limits**: Check AWS service limits
4. **Dependencies**: Some resources have implicit dependencies

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resources
terraform import aws_s3_bucket.example bucket-name

# Destroy specific resources
terraform destroy -target=aws_s3_bucket.example

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## Cost Optimization

- **Redshift Serverless**: Pay-per-use pricing
- **S3 Lifecycle**: Automatic data archival
- **Lambda**: Serverless compute
- **CloudWatch Logs**: Retention policies
- **SageMaker**: On-demand instances

## Maintenance

### Regular Tasks

1. **Update Terraform**: Keep providers and modules updated
2. **Rotate Secrets**: Update DHIS2 credentials regularly
3. **Monitor Costs**: Review budgets and usage
4. **Security Reviews**: Audit IAM policies and permissions
5. **Backup Verification**: Test data recovery procedures

### Scaling Considerations

- **Redshift**: Adjust base capacity based on usage
- **Lambda**: Monitor concurrency and memory usage
- **S3**: Implement lifecycle policies for cost optimization
- **SageMaker**: Scale instances based on ML workload

## Support

For issues and questions:

1. Check the troubleshooting section
2. Review AWS documentation
3. Check Terraform provider documentation
4. Create an issue in the repository

## License

This project is licensed under the MIT License.