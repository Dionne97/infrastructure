# Athena Workgroup and Configuration

# S3 bucket for Athena query results
resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.name_prefix}-athena-results"
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-athena-results"
  })
}

resource "aws_s3_bucket_versioning" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Athena Workgroup
resource "aws_athena_workgroup" "validation" {
  name = "${var.name_prefix}-validation"
  
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/results/"
      
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
  
  tags = var.common_tags
}

# Named queries for smoke tests
resource "aws_athena_named_query" "row_count_raw" {
  name        = "${var.name_prefix}-row-count-raw"
  workgroup   = aws_athena_workgroup.validation.id
  database    = "${var.name_prefix}_raw"
  description = "Count rows in raw data tables"
  
  query = <<EOF
SELECT 
  table_name,
  row_count
FROM (
  SELECT 'organizations' as table_name, COUNT(*) as row_count FROM organizations
  UNION ALL
  SELECT 'facilities' as table_name, COUNT(*) as row_count FROM facilities
  UNION ALL
  SELECT 'indicators' as table_name, COUNT(*) as row_count FROM indicators
) t
ORDER BY table_name;
EOF
}

resource "aws_athena_named_query" "row_count_curated" {
  name        = "${var.name_prefix}-row-count-curated"
  workgroup   = aws_athena_workgroup.validation.id
  database    = "${var.name_prefix}_curated"
  description = "Count rows in curated data tables"
  
  query = <<EOF
SELECT 
  table_name,
  row_count
FROM (
  SELECT 'harmonized_data' as table_name, COUNT(*) as row_count FROM harmonized_data
  UNION ALL
  SELECT 'mfr_joined' as table_name, COUNT(*) as row_count FROM mfr_joined
) t
ORDER BY table_name;
EOF
}

resource "aws_athena_named_query" "schema_validation" {
  name        = "${var.name_prefix}-schema-validation"
  workgroup   = aws_athena_workgroup.validation.id
  database    = "${var.name_prefix}_curated"
  description = "Validate schema of curated tables"
  
  query = <<EOF
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = '${var.name_prefix}_curated'
  AND table_name IN ('harmonized_data', 'mfr_joined')
ORDER BY table_name, ordinal_position;
EOF
}

# IAM policy for Athena access
resource "aws_iam_policy" "athena_access" {
  name        = "${var.name_prefix}-athena-access"
  description = "Policy for Athena access to data lake"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetWorkGroup"
        ]
        Resource = [
          aws_athena_workgroup.validation.arn,
          "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/${aws_athena_workgroup.validation.name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_names.raw_data}",
          "arn:aws:s3:::${var.bucket_names.raw_data}/*",
          "arn:aws:s3:::${var.bucket_names.curated_data}",
          "arn:aws:s3:::${var.bucket_names.curated_data}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:GetPartitions"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
