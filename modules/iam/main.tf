# IAM Roles and Policies for HEAL MVP

# Lambda execution role
resource "aws_iam_role" "lambda_execution" {
  name = "${var.name_prefix}-lambda-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Lambda ingest role
resource "aws_iam_role" "lambda_ingest" {
  name = "${var.name_prefix}-lambda-ingest-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_ingest" {
  name = "${var.name_prefix}-lambda-ingest-policy"
  role = aws_iam_role.lambda_ingest.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-raw/*",
          "arn:aws:s3:::${var.name_prefix}-quarantine/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arns["s3_data"]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.dhis2_credentials.arn
      }
    ]
  })
}

# Lambda validator role
resource "aws_iam_role" "lambda_validator" {
  name = "${var.name_prefix}-lambda-validator-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_validator" {
  name = "${var.name_prefix}-lambda-validator-policy"
  role = aws_iam_role.lambda_validator.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-raw/*",
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-quarantine/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arns["s3_data"]
      }
    ]
  })
}

# Lambda API role
resource "aws_iam_role" "lambda_api" {
  name = "${var.name_prefix}-lambda-api-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_api" {
  name = "${var.name_prefix}-lambda-api-policy"
  role = aws_iam_role.lambda_api.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-features/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arns["s3_data"]
      },
      {
        Effect = "Allow"
        Action = [
          "quicksight:GetDashboardEmbedUrl",
          "quicksight:GetSessionEmbedUrl"
        ]
        Resource = "*"
      }
    ]
  })
}

# Glue job role
resource "aws_iam_role" "glue_job" {
  name = "${var.name_prefix}-glue-job-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_job.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_job" {
  name = "${var.name_prefix}-glue-job-policy"
  role = aws_iam_role.glue_job.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-raw",
          "arn:aws:s3:::${var.name_prefix}-raw/*",
          "arn:aws:s3:::${var.name_prefix}-curated",
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-features",
          "arn:aws:s3:::${var.name_prefix}-features/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arns["glue"]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:CreateTable",
          "glue:UpdateTable"
        ]
        Resource = "*"
      }
    ]
  })
}

# Glue crawler role
resource "aws_iam_role" "glue_crawler" {
  name = "${var.name_prefix}-glue-crawler-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_crawler_service_role" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_crawler" {
  name = "${var.name_prefix}-glue-crawler-policy"
  role = aws_iam_role.glue_crawler.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-raw",
          "arn:aws:s3:::${var.name_prefix}-raw/*",
          "arn:aws:s3:::${var.name_prefix}-curated",
          "arn:aws:s3:::${var.name_prefix}-curated/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arns["s3_data"]
      }
    ]
  })
}

# Redshift service role
resource "aws_iam_role" "redshift" {
  name = "${var.name_prefix}-redshift-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "redshift" {
  name = "${var.name_prefix}-redshift-policy"
  role = aws_iam_role.redshift.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-curated",
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-features",
          "arn:aws:s3:::${var.name_prefix}-features/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arns["redshift"]
      }
    ]
  })
}

# SageMaker execution role
resource "aws_iam_role" "sagemaker" {
  name = "${var.name_prefix}-sagemaker-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "sagemaker" {
  name = "${var.name_prefix}-sagemaker-policy"
  role = aws_iam_role.sagemaker.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-curated",
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-features",
          "arn:aws:s3:::${var.name_prefix}-features/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arns["s3_data"]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# QuickSight access role
resource "aws_iam_role" "quicksight" {
  name = "${var.name_prefix}-quicksight-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "quicksight" {
  name = "${var.name_prefix}-quicksight-policy"
  role = aws_iam_role.quicksight.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-curated",
          "arn:aws:s3:::${var.name_prefix}-curated/*",
          "arn:aws:s3:::${var.name_prefix}-features",
          "arn:aws:s3:::${var.name_prefix}-features/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arns["s3_data"]
      },
      {
        Effect = "Allow"
        Action = [
          "redshift:DescribeClusters",
          "redshift:DescribeClusterSubnetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secrets Manager secrets
resource "aws_secretsmanager_secret" "dhis2_credentials" {
  name        = "${var.name_prefix}-dhis2-credentials"
  description = "DHIS2 API credentials"
  kms_key_id  = var.kms_key_arns["secrets"]
  
  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "dhis2_credentials" {
  secret_id = aws_secretsmanager_secret.dhis2_credentials.id
  secret_string = jsonencode({
    base_url = var.dhis2_base_url
    username = var.dhis2_username
    password = var.dhis2_password
  })
}

# SNS topic for notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.name_prefix}-notifications"
  
  tags = var.common_tags
}

resource "aws_sns_topic_policy" "notifications" {
  arn = aws_sns_topic.notifications.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "lambda.amazonaws.com",
            "stepfunctions.amazonaws.com"
          ]
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.notifications.arn
      }
    ]
  })
}

# SNS topic subscription (email)
resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
