# Staging Environment Configuration

terraform {
  required_version = ">= 1.0"
  
  # Backend configuration for staging environment
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "user-gateway/staging/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Include root module
module "secure_iam" {
  source = "../.."

  project_name             = "user-gateway"
  environment              = "staging"
  aws_region               = "us-east-1"
  enable_mfa               = true   # MFA enabled
  enable_advanced_security = true   # Advanced security enabled
  api_throttle_rate        = 500
  api_throttle_burst       = 1000

  tags = {
    Environment = "staging"
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
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
