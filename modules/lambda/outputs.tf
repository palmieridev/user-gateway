# Lambda Module - Outputs

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.profile_handler.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.profile_handler.arn
}

output "function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.profile_handler.invoke_arn
}

output "function_version" {
  description = "The version of the Lambda function"
  value       = aws_lambda_function.profile_handler.version
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
}
