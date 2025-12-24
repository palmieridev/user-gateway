# IAM Module

This module creates IAM roles and policies for the Secure IAM infrastructure, following the principle of least privilege.

## Features

- ✅ Lambda execution role
- ✅ CloudWatch Logs permissions
- ✅ X-Ray tracing permissions
- ✅ Least-privilege policies
- ✅ Service-specific roles
- ✅ Extensible for additional permissions

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  project_name = "my-project"
  environment  = "dev"
  
  tags = {
    Environment = "dev"
  }
}
```

## Security Principles

- **Least Privilege**: Only necessary permissions are granted
- **Separation of Duties**: Different roles for different services
- **Explicit Deny**: No wildcards unless absolutely necessary
- **Regular Audits**: Policies are version-controlled and reviewable

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | n/a | yes |
| environment | Environment name | string | n/a | yes |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_role_arn | ARN of the Lambda execution role |
| lambda_role_name | Name of the Lambda execution role |
