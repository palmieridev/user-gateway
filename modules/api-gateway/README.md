# API Gateway Module

This module creates and configures AWS API Gateway with Cognito authorizer for secure API access control.

## Features

- ✅ REST API Gateway
- ✅ Cognito User Pool Authorizer
- ✅ CORS configuration
- ✅ Request/Response validation
- ✅ API stages (dev, staging, prod)
- ✅ CloudWatch logging
- ✅ Throttling and rate limiting
- ✅ Lambda proxy integration
- ✅ Custom domain support (ready)

## Usage

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name          = "my-project"
  environment           = "dev"
  cognito_user_pool_arn = "arn:aws:cognito-idp:..."
  lambda_invoke_arn     = "arn:aws:lambda:..."
  
  tags = {
    Environment = "dev"
  }
}
```

## Endpoints

The API Gateway creates the following endpoints:

- `GET /profile` - Get user profile (protected)
- `PUT /profile` - Update user profile (protected)
- `GET /health` - Health check (public)

## Security

- All protected endpoints require valid Cognito JWT tokens
- Token validation is automatic via Cognito authorizer
- CORS is configured to prevent unauthorized origins
- Rate limiting prevents abuse

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | n/a | yes |
| environment | Environment name | string | n/a | yes |
| cognito_user_pool_arn | ARN of Cognito User Pool | string | n/a | yes |
| lambda_invoke_arn | ARN of Lambda function | string | n/a | yes |
| throttle_rate | Throttle rate limit | number | 1000 | no |
| throttle_burst | Throttle burst limit | number | 2000 | no |

## Outputs

| Name | Description |
|------|-------------|
| api_id | The ID of the API Gateway |
| api_url | The URL of the API Gateway |
| api_arn | The ARN of the API Gateway |
| authorizer_id | The ID of the Cognito authorizer |
