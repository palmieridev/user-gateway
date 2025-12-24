# Cognito User Pool Module - Outputs

output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "The endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "client_id" {
  description = "The ID of the User Pool Client"
  value       = aws_cognito_user_pool_client.main.id
  sensitive   = true
}

output "client_secret" {
  description = "The secret of the User Pool Client"
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}

output "user_pool_domain" {
  description = "The domain of the User Pool"
  value       = var.user_pool_domain != "" ? aws_cognito_user_pool_domain.main[0].domain : null
}
