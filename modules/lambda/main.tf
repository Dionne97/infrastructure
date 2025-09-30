# Lambda Functions for HEAL MVP

# Lambda: DHIS2 Puller
resource "aws_lambda_function" "dhis2_puller" {
  filename         = data.archive_file.dhis2_puller.output_path
  function_name    = "${var.name_prefix}-dhis2-puller"
  role            = var.lambda_role_arns.ingest
  handler         = "index.handler"
  source_code_hash = data.archive_file.dhis2_puller.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300
  
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      DHIS2_SECRET_ARN = var.secrets_manager_arn
      RAW_BUCKET       = var.bucket_names.raw_data
      QUARANTINE_BUCKET = var.bucket_names.quarantine
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.dhis2_puller]
}

resource "aws_cloudwatch_log_group" "dhis2_puller" {
  name              = "/aws/lambda/${var.name_prefix}-dhis2-puller"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Lambda: S3 Validator
resource "aws_lambda_function" "s3_validator" {
  filename         = data.archive_file.s3_validator.output_path
  function_name    = "${var.name_prefix}-s3-validator"
  role            = var.lambda_role_arns.validator
  handler         = "index.handler"
  source_code_hash = data.archive_file.s3_validator.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300
  
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      RAW_BUCKET       = var.bucket_names.raw_data
      CURATED_BUCKET   = var.bucket_names.curated_data
      QUARANTINE_BUCKET = var.bucket_names.quarantine
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.s3_validator]
}

resource "aws_cloudwatch_log_group" "s3_validator" {
  name              = "/aws/lambda/${var.name_prefix}-s3-validator"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Lambda: Curated to Redshift Loader
resource "aws_lambda_function" "redshift_loader" {
  filename         = data.archive_file.redshift_loader.output_path
  function_name    = "${var.name_prefix}-redshift-loader"
  role            = var.lambda_role_arns.execution
  handler         = "index.handler"
  source_code_hash = data.archive_file.redshift_loader.output_base64sha256
  runtime         = "python3.9"
  timeout         = 900
  
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      REDSHIFT_ENDPOINT = var.redshift_endpoint
      CURATED_BUCKET    = var.bucket_names.curated_data
      FEATURES_BUCKET   = var.bucket_names.features_data
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.redshift_loader]
}

resource "aws_cloudwatch_log_group" "redshift_loader" {
  name              = "/aws/lambda/${var.name_prefix}-redshift-loader"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Lambda: Post-ML Publisher
resource "aws_lambda_function" "ml_publisher" {
  filename         = data.archive_file.ml_publisher.output_path
  function_name    = "${var.name_prefix}-ml-publisher"
  role            = var.lambda_role_arns.execution
  handler         = "index.handler"
  source_code_hash = data.archive_file.ml_publisher.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300
  
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      FEATURES_BUCKET = var.bucket_names.features_data
      REDSHIFT_ENDPOINT = var.redshift_endpoint
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.ml_publisher]
}

resource "aws_cloudwatch_log_group" "ml_publisher" {
  name              = "/aws/lambda/${var.name_prefix}-ml-publisher"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Lambda: QuickSight Embed URL Signer
resource "aws_lambda_function" "quicksight_embed" {
  filename         = data.archive_file.quicksight_embed.output_path
  function_name    = "${var.name_prefix}-quicksight-embed"
  role            = var.lambda_role_arns.api
  handler         = "index.handler"
  source_code_hash = data.archive_file.quicksight_embed.output_base64sha256
  runtime         = "python3.9"
  timeout         = 60
  
  environment {
    variables = {
      QUICKSIGHT_DASHBOARD_ID = "heal-dashboard"
      QUICKSIGHT_NAMESPACE    = "default"
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.quicksight_embed]
}

resource "aws_cloudwatch_log_group" "quicksight_embed" {
  name              = "/aws/lambda/${var.name_prefix}-quicksight-embed"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Lambda: Dashboard API
resource "aws_lambda_function" "dashboard_api" {
  filename         = data.archive_file.dashboard_api.output_path
  function_name    = "${var.name_prefix}-dashboard-api"
  role            = var.lambda_role_arns.api
  handler         = "index.handler"
  source_code_hash = data.archive_file.dashboard_api.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30
  
  environment {
    variables = {
      CURATED_BUCKET  = var.bucket_names.curated_data
      FEATURES_BUCKET = var.bucket_names.features_data
    }
  }
  
  tags = var.common_tags
  
  depends_on = [aws_cloudwatch_log_group.dashboard_api]
}

resource "aws_cloudwatch_log_group" "dashboard_api" {
  name              = "/aws/lambda/${var.name_prefix}-dashboard-api"
  retention_in_days = 14
  
  tags = var.common_tags
}

# Security Group for Lambda functions
resource "aws_security_group" "lambda" {
  name_prefix = "${var.name_prefix}-lambda-"
  vpc_id      = data.aws_vpc.main.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-sg"
  })
}

# Archive files for Lambda functions (placeholders)
data "archive_file" "dhis2_puller" {
  type        = "zip"
  output_path = "/tmp/dhis2_puller.zip"
  
  source {
    content = <<EOF
import json
import boto3
import requests
from datetime import datetime

def handler(event, context):
    # Placeholder for DHIS2 data pulling logic
    return {
        'statusCode': 200,
        'body': json.dumps('DHIS2 data pulled successfully')
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "s3_validator" {
  type        = "zip"
  output_path = "/tmp/s3_validator.zip"
  
  source {
    content = <<EOF
import json
import boto3

def handler(event, context):
    # Placeholder for S3 data validation logic
    return {
        'statusCode': 200,
        'body': json.dumps('Data validation completed')
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "redshift_loader" {
  type        = "zip"
  output_path = "/tmp/redshift_loader.zip"
  
  source {
    content = <<EOF
import json
import boto3

def handler(event, context):
    # Placeholder for Redshift loading logic
    return {
        'statusCode': 200,
        'body': json.dumps('Data loaded to Redshift successfully')
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "ml_publisher" {
  type        = "zip"
  output_path = "/tmp/ml_publisher.zip"
  
  source {
    content = <<EOF
import json
import boto3

def handler(event, context):
    # Placeholder for ML publishing logic
    return {
        'statusCode': 200,
        'body': json.dumps('ML features published successfully')
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "quicksight_embed" {
  type        = "zip"
  output_path = "/tmp/quicksight_embed.zip"
  
  source {
    content = <<EOF
import json
import boto3

def handler(event, context):
    # Placeholder for QuickSight embed URL generation
    return {
        'statusCode': 200,
        'body': json.dumps('QuickSight embed URL generated')
    }
EOF
    filename = "index.py"
  }
}

data "archive_file" "dashboard_api" {
  type        = "zip"
  output_path = "/tmp/dashboard_api.zip"
  
  source {
    content = <<EOF
import json
import boto3

def handler(event, context):
    # Placeholder for dashboard API logic
    return {
        'statusCode': 200,
        'body': json.dumps('Dashboard API response')
    }
EOF
    filename = "index.py"
  }
}

# Data sources
data "aws_vpc" "main" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  
  tags = {
    Type = "Private"
  }
}
