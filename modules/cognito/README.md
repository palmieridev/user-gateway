# AWS Cognito User Pool Module

This module creates and configures an AWS Cognito User Pool with comprehensive security features including MFA, advanced security, and customizable authentication flows.

## Features

- ✅ User Pool with customizable schema
- ✅ Multi-Factor Authentication (MFA) - SMS & TOTP
- ✅ Password policies and complexity requirements
- ✅ Advanced security features (risk-based authentication)
- ✅ Email and SMS verification
- ✅ Account recovery mechanisms
- ✅ Custom domain support
- ✅ Lambda trigger integration points
- ✅ User Pool Client for application integration

## Usage

```hcl
module "cognito" {
  source = "./modules/cognito"

  project_name             = "my-project"
  environment              = "dev"
  enable_mfa               = true
  enable_advanced_security = true
  
  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | n/a | yes |
| environment | Environment name | string | n/a | yes |
| enable_mfa | Enable MFA | bool | true | no |
| enable_advanced_security | Enable advanced security | bool | true | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | The ID of the User Pool |
| user_pool_arn | The ARN of the User Pool |
| user_pool_endpoint | The endpoint of the User Pool |
| client_id | The ID of the User Pool Client |
| client_secret | The secret of the User Pool Client |

## Security Considerations

- MFA is enabled by default for enhanced security
- Password policies enforce strong passwords
- Advanced security features detect and prevent compromised credentials
- Account takeover protection is enabled
- All data is encrypted at rest
