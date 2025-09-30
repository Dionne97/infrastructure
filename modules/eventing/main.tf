# EventBridge, Step Functions, and SQS

# EventBridge Rules
resource "aws_cloudwatch_event_rule" "dhis2_ingestion" {
  name                = "${var.name_prefix}-dhis2-ingestion"
  description         = "Trigger DHIS2 data ingestion"
  schedule_expression = "rate(1 day)" # Daily at midnight UTC
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_rule" "validation_pipeline" {
  name                = "${var.name_prefix}-validation-pipeline"
  description         = "Trigger validation pipeline"
  schedule_expression = "rate(2 hours)" # Every 2 hours
  
  tags = var.common_tags
}

# EventBridge Targets
resource "aws_cloudwatch_event_target" "dhis2_ingestion" {
  rule      = aws_cloudwatch_event_rule.dhis2_ingestion.name
  target_id = "Dhis2IngestionTarget"
  arn       = aws_sfn_state_machine.main.arn
  
  input = jsonencode({
    "source": "eventbridge",
    "type": "dhis2_ingestion"
  })
}

resource "aws_cloudwatch_event_target" "validation_pipeline" {
  rule      = aws_cloudwatch_event_rule.validation_pipeline.name
  target_id = "ValidationPipelineTarget"
  arn       = aws_sfn_state_machine.main.arn
  
  input = jsonencode({
    "source": "eventbridge",
    "type": "validation_pipeline"
  })
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "main" {
  name     = "${var.name_prefix}-data-pipeline"
  role_arn = aws_iam_role.step_functions.arn
  
  definition = jsonencode({
    Comment = "HEAL MVP Data Pipeline"
    StartAt = "IngestData"
    States = {
      IngestData = {
        Type     = "Task"
        Resource = var.lambda_function_arns.dhis2_puller
        Next     = "ValidateData"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
            ResultPath  = "$.error"
          }
        ]
      }
      ValidateData = {
        Type     = "Task"
        Resource = var.lambda_function_arns.s3_validator
        Next     = "HarmonizeData"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
            ResultPath  = "$.error"
          }
        ]
      }
      HarmonizeData = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "${var.name_prefix}-harmonize-job"
        }
        Next = "LoadRedshift"
        Retry = [
          {
            ErrorEquals     = ["Glue.AWSGlueException"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
            ResultPath  = "$.error"
          }
        ]
      }
      LoadRedshift = {
        Type     = "Task"
        Resource = var.lambda_function_arns.redshift_loader
        Next     = "PublishFeatures"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
            ResultPath  = "$.error"
          }
        ]
      }
      PublishFeatures = {
        Type     = "Task"
        Resource = var.lambda_function_arns.ml_publisher
        Next     = "NotifySuccess"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
            ResultPath  = "$.error"
          }
        ]
      }
      NotifySuccess = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.sns_topic_arn
          Message  = "HEAL MVP Data Pipeline completed successfully"
          Subject  = "Pipeline Success"
        }
        End = true
      }
      NotifyFailure = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.sns_topic_arn
          Message  = "HEAL MVP Data Pipeline failed: $.error"
          Subject  = "Pipeline Failure"
        }
        End = true
      }
    }
  })
  
  tags = var.common_tags
}

# Step Functions IAM Role
resource "aws_iam_role" "step_functions" {
  name = "${var.name_prefix}-step-functions-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "step_functions" {
  name = "${var.name_prefix}-step-functions-policy"
  role = aws_iam_role.step_functions.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = values(var.lambda_function_arns)
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
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

# SQS Dead Letter Queues
resource "aws_sqs_queue" "dhis2_puller_dlq" {
  name = "${var.name_prefix}-dhis2-puller-dlq"
  
  message_retention_seconds = 1209600 # 14 days
  
  tags = var.common_tags
}

resource "aws_sqs_queue" "s3_validator_dlq" {
  name = "${var.name_prefix}-s3-validator-dlq"
  
  message_retention_seconds = 1209600 # 14 days
  
  tags = var.common_tags
}

# SQS Queues for Lambda triggers
resource "aws_sqs_queue" "s3_validation" {
  name = "${var.name_prefix}-s3-validation"
  
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600 # 14 days
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.s3_validator_dlq.arn
    maxReceiveCount     = 3
  })
  
  tags = var.common_tags
}

# S3 Event Notifications to SQS
resource "aws_s3_bucket_notification" "raw_data" {
  bucket = var.bucket_names.raw_data
  
  queue {
    queue_arn = aws_sqs_queue.s3_validation.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = "organizations/"
  }
  
  queue {
    queue_arn = aws_sqs_queue.s3_validation.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = "facilities/"
  }
  
  queue {
    queue_arn = aws_sqs_queue.s3_validation.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = "indicators/"
  }
}

# SQS Queue Policy
resource "aws_sqs_queue_policy" "s3_validation" {
  queue_url = aws_sqs_queue.s3_validation.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.s3_validation.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:s3:::${var.bucket_names.raw_data}"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/stepfunctions/${var.name_prefix}-data-pipeline"
  retention_in_days = 14
  
  tags = var.common_tags
}
