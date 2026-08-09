output "lambda_function_name" {
  description = "Name of the Watch collector Lambda function"
  value       = module.watch.lambda_function_name
}

output "dynamodb_table_name" {
  description = "Name of the events table"
  value       = module.watch.dynamodb_table_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for debugging"
  value       = module.watch.cloudwatch_log_group
}
