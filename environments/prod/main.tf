# Production Environment Configuration

terraform {
  required_version = ">= 1.0"
  
  # Backend configuration for production environment
  # IMPORTANT: Configure remote state before deploying to production
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "user-gateway/prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Include root module
module "secure_iam" {
  source = "../.."

  project_name             = "user-gateway"
  environment              = "prod"
  aws_region               = "us-east-1"
  enable_mfa               = true   # MFA required in production
  enable_advanced_security = true   # Advanced security required
  api_throttle_rate        = 1000   # Production limits
  api_throttle_burst       = 2000

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Owner       = "Platform"
    Criticality = "High"
    Compliance  = "Required"
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
