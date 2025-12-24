# Lambda Functions Module

This module creates AWS Lambda functions for handling API requests and business logic behind the API Gateway.

## Features

- ✅ Lambda function with configurable runtime
- ✅ CloudWatch log integration
- ✅ Environment variable support
- ✅ IAM role integration
- ✅ Python runtime (easily adaptable to Node.js, Go, etc.)
- ✅ Lambda layers support (ready)
- ✅ VPC configuration (ready)

## Usage

```hcl
module "lambda" {
  source = "./modules/lambda"

  project_name    = "my-project"
  environment     = "dev"
  lambda_role_arn = "arn:aws:iam::..."
  
  tags = {
    Environment = "dev"
  }
}
```

## Functions

- **Profile Handler**: Handles GET and PUT requests for user profiles
- Extracts user information from Cognito JWT claims
- Implements authorization checks

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | n/a | yes |
| environment | Environment name | string | n/a | yes |
| lambda_role_arn | ARN of Lambda execution role | string | n/a | yes |
| runtime | Lambda runtime | string | "python3.11" | no |
| timeout | Function timeout in seconds | number | 30 | no |
| memory_size | Function memory in MB | number | 128 | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | The name of the Lambda function |
| function_arn | The ARN of the Lambda function |
| function_invoke_arn | The invoke ARN of the Lambda function |
| log_group_name | The name of the CloudWatch log group |
