# API Gateway Module - Outputs

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  description = "The ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_url" {
  description = "The URL of the API Gateway deployment"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "authorizer_id" {
  description = "The ID of the Cognito authorizer"
  value       = aws_api_gateway_authorizer.cognito.id
}

output "stage_name" {
  description = "The name of the deployment stage"
  value       = aws_api_gateway_stage.main.stage_name
}

output "execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}
