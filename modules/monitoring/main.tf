# Monitoring, logging, and budgets

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_dhis2_puller" {
  name              = "/aws/lambda/${var.name_prefix}-dhis2-puller"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_s3_validator" {
  name              = "/aws/lambda/${var.name_prefix}-s3-validator"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_redshift_loader" {
  name              = "/aws/lambda/${var.name_prefix}-redshift-loader"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_ml_publisher" {
  name              = "/aws/lambda/${var.name_prefix}-ml-publisher"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_quicksight_embed" {
  name              = "/aws/lambda/${var.name_prefix}-quicksight-embed"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_dashboard_api" {
  name              = "/aws/lambda/${var.name_prefix}-dashboard-api"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.name_prefix}-api"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/stepfunctions/${var.name_prefix}-data-pipeline"
  retention_in_days = 14
  
  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "glue_jobs" {
  name              = "/aws-glue/jobs/${var.name_prefix}"
  retention_in_days = 14
  
  tags = var.common_tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = length(var.lambda_function_arns)
  
  alarm_name          = "${var.name_prefix}-lambda-errors-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors lambda errors"
  
  dimensions = {
    FunctionName = values(var.lambda_function_arns)[count.index]
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count = length(var.lambda_function_arns)
  
  alarm_name          = "${var.name_prefix}-lambda-throttles-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors lambda throttles"
  
  dimensions = {
    FunctionName = values(var.lambda_function_arns)[count.index]
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  alarm_name          = "${var.name_prefix}-api-gateway-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  
  dimensions = {
    ApiName = var.api_gateway_id
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "redshift_concurrency" {
  alarm_name          = "${var.name_prefix}-redshift-concurrency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/Redshift"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Redshift concurrency"
  
  dimensions = {
    WorkgroupName = var.redshift_workgroup_name
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "step_functions_failures" {
  alarm_name          = "${var.name_prefix}-step-functions-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors Step Functions failures"
  
  dimensions = {
    StateMachineArn = var.step_functions_arn
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

# Custom metrics for S3 ingest lag
resource "aws_cloudwatch_log_metric_filter" "s3_ingest_lag" {
  name           = "${var.name_prefix}-s3-ingest-lag"
  log_group_name = aws_cloudwatch_log_group.lambda_dhis2_puller.name
  pattern        = "[timestamp, request_id, level, message]"
  
  metric_transformation {
    name      = "S3IngestLag"
    namespace = "HEAL/Custom"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_ingest_lag" {
  alarm_name          = "${var.name_prefix}-s3-ingest-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "S3IngestLag"
  namespace           = "HEAL/Custom"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors S3 ingest lag"
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.common_tags
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
  
  tags = var.common_tags
}

resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn
  
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
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# SNS Topic Subscription (email)
resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Cost Anomaly Detection
resource "aws_ce_anomaly_detector" "main" {
  name = "${var.name_prefix}-cost-anomaly-detector"
  
  specification = "DAILY_COST"
  
  monitor_type = "DIMENSIONAL"
  
  dimension = "SERVICE"
  
  tags = var.common_tags
}

# Budget
resource "aws_budgets_budget" "main" {
  name         = "${var.name_prefix}-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filters = {
    Tag = [
      "Project:${var.name_prefix}"
    ]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.notification_email != "" ? [var.notification_email] : []
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = var.notification_email != "" ? [var.notification_email] : []
  }
  
  tags = var.common_tags
}

# Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", values(var.lambda_function_arns)[0]],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_id],
            [".", "4XXError", ".", "."],
            [".", "5XXError", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "API Gateway Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/Redshift", "DatabaseConnections", "WorkgroupName", var.redshift_workgroup_name],
            [".", "QueryDuration", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Redshift Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Data source
data "aws_region" "current" {}
