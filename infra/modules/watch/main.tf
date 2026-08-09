/**
 * Rigel Watch - Terraform Module
 * Provisions Lambda, EventBridge, and DynamoDB for event collection
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DynamoDB table to store events
resource "aws_dynamodb_table" "events" {
  name           = "${var.project_name}-events-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "processed"
    type = "S"
  }

  global_secondary_index {
    name            = "ProcessedIndex"
    hash_key        = "processed"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = {
    Name        = "${var.project_name}-events"
    Environment = var.environment
    Module      = "rigel-watch"
  }
}

# Lambda function for event collection
resource "aws_lambda_function" "collector" {
  filename         = var.lambda_zip_path
  function_name    = "${var.project_name}-watch-collector-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "collector.lambda_handler"
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      EVENTS_TABLE_NAME = aws_dynamodb_table.events.name
      ENVIRONMENT       = var.environment
    }
  }

  tags = {
    Name        = "${var.project_name}-watch-collector"
    Environment = var.environment
    Module      = "rigel-watch"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.collector.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-watch-logs"
    Environment = var.environment
  }
}

# EventBridge rule for EC2 state changes
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "${var.project_name}-ec2-state-change-${var.environment}"
  description = "Capture EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "stopping", "terminated", "terminating"]
    }
  })

  tags = {
    Name        = "${var.project_name}-ec2-state-change"
    Environment = var.environment
  }
}

# EventBridge target - Lambda function
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "RigelWatchCollector"
  arn       = aws_lambda_function.collector.arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}

# EventBridge rule for EC2 status check failures
resource "aws_cloudwatch_event_rule" "ec2_status_check_failed" {
  name        = "${var.project_name}-ec2-status-check-failed-${var.environment}"
  description = "Capture EC2 instance status check failures"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service = ["EC2"]
      eventTypeCategory = ["issue"]
    }
  })

  tags = {
    Name        = "${var.project_name}-ec2-status-check"
    Environment = var.environment
  }
}

# EventBridge target for status check failures
resource "aws_cloudwatch_event_target" "lambda_status_check" {
  rule      = aws_cloudwatch_event_rule.ec2_status_check_failed.name
  target_id = "RigelWatchCollectorStatusCheck"
  arn       = aws_lambda_function.collector.arn
}

# Permission for status check EventBridge rule
resource "aws_lambda_permission" "allow_eventbridge_status_check" {
  statement_id  = "AllowExecutionFromEventBridgeStatusCheck"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_status_check_failed.arn
}
