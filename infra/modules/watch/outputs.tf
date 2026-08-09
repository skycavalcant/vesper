/**
 * Output values for Rigel Watch module
 */

output "lambda_function_arn" {
  description = "ARN of the collector Lambda function"
  value       = aws_lambda_function.collector.arn
}

output "lambda_function_name" {
  description = "Name of the collector Lambda function"
  value       = aws_lambda_function.collector.function_name
}

output "dynamodb_table_name" {
  description = "Name of the events DynamoDB table"
  value       = aws_dynamodb_table.events.name
}

output "dynamodb_table_arn" {
  description = "ARN of the events DynamoDB table"
  value       = aws_dynamodb_table.events.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.ec2_state_change.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
