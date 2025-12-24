# Development Environment Configuration

terraform {
  required_version = ">= 1.0"
  
  # Backend configuration for dev environment
  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "user-gateway/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Include root module
module "secure_iam" {
  source = "../.."

  project_name             = "user-gateway"
  environment              = "dev"
  aws_region               = "us-east-1"
  enable_mfa               = false  # Disabled for dev convenience
  enable_advanced_security = false  # Disabled for dev to reduce costs
  api_throttle_rate        = 100    # Lower limits for dev
  api_throttle_burst       = 200

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "DevTeam"
  }
}

# Outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.secure_iam.cognito_user_pool_id
}

output "cognito_client_id" {
  description = "Cognito Client ID"
  value       = module.secure_iam.cognito_client_id
  sensitive   = true
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.secure_iam.api_gateway_url
}

output "region" {
  description = "AWS Region"
  value       = module.secure_iam.region
}
