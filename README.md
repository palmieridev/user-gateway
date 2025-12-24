# User Gateway

A production-ready identity and access management infrastructure built with Terraform, featuring AWS Cognito for authentication and API Gateway for secure API access control.

## Project Overview

- Multi-Factor Authentication (MFA)
- JWT Token Validation
- Secure API Access with API Gateway
- User Pool Management with AWS Cognito
- OAuth 2.0 / OIDC Support
- Role-Based Access Control (RBAC)
- Infrastructure as Code with Terraform
- Multi-environment support (dev/staging/prod)
- Cloud-agnostic design patterns

## Architecture

### System Architecture

```mermaid
graph TB
    Client[Client Application]
    APIGW[API Gateway]
    Cognito[Cognito User Pool]
    Lambda[Lambda Functions]
    IAM[IAM Roles & Policies]
    CW[CloudWatch Logs]
    
    Client -->|HTTPS Request| APIGW
    APIGW -->|Validate Token| Cognito
    Cognito -->|Token Valid| APIGW
    APIGW -->|Invoke| Lambda
    Lambda -->|Assume Role| IAM
    Lambda -->|Logs| CW
    APIGW -->|Logs| CW
    
    style Cognito fill:#FF9900
    style APIGW fill:#FF9900
    style Lambda fill:#FF9900
```

### Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant Client
    participant Cognito
    participant APIGateway
    participant Lambda
    
    User->>Client: Enter Credentials
    Client->>Cognito: Sign In Request
    
    alt MFA Enabled
        Cognito->>User: Request MFA Code
        User->>Cognito: Submit MFA Code
    end
    
    Cognito->>Client: Return JWT Tokens
    Client->>APIGateway: API Request + ID Token
    APIGateway->>Cognito: Validate Token
    Cognito->>APIGateway: Token Valid
    APIGateway->>Lambda: Invoke Function
    Lambda->>APIGateway: Response
    APIGateway->>Client: API Response
    Client->>User: Display Result
```

### Key Components

1. **AWS Cognito User Pool**: Manages user registration, authentication, and MFA
2. **API Gateway**: Provides secure REST API endpoints with Cognito authorizers
3. **Lambda Functions**: Backend logic for protected resources
4. **IAM Roles & Policies**: Least-privilege access control

## Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- An AWS account with necessary permissions

### Installation

```bash
# Initialize Terraform
cd environments/dev
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

### Configuration

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update variables with your specific values
3. Ensure AWS credentials are configured

```bash
export AWS_PROFILE=profile
export AWS_REGION=us-east-1
```

##  Project Structure

```
user-gateway/
├── modules/
│   ├── cognito/              # Cognito User Pool & Client configuration
│   ├── api-gateway/          # API Gateway with Cognito authorizer
│   ├── lambda/               # Lambda functions for API backend
│   └── iam/                  # IAM roles and policies
├── environments/
│   ├── dev/                  # Development environment
│   ├── staging/              # Staging environment
│   └── prod/                 # Production environment
├── scripts/                  # Utility scripts for testing/deployment
├── .gitignore
├── .terraform-version
├── AGENTS.md                 # Development guide
└── README.md                 # This file
```

##  Security Features

### Multi-Factor Authentication (MFA)
- SMS-based MFA
- TOTP (Time-based One-Time Password) support
- Configurable MFA requirements per user pool

### Token Validation
- JWT token verification
- Token expiration handling
- Refresh token rotation
- Secure token storage patterns

### API Security
- Cognito authorizers on all protected endpoints
- Request validation
- Rate limiting and throttling
- CORS configuration
- API key management (optional)

### Compliance & Best Practices
- Encryption at rest and in transit
- Password policies (complexity, rotation)
- Account recovery mechanisms
- Audit logging with CloudWatch
- Secrets management (AWS Secrets Manager integration ready)

##  Attack Surface Protection

This implementation protects against common attack vectors:

- **Brute Force Attacks**: Rate limiting, account lockout policies
- **Credential Stuffing**: MFA enforcement, advanced security features
- **Token Theft**: Short-lived tokens, token rotation
- **CSRF**: Token-based authentication
- **SQL Injection**: Parameterized queries in Lambda functions
- **DDoS**: API Gateway throttling, WAF integration ready

##  Module Documentation

### Cognito Module
Creates and configures AWS Cognito User Pool with:
- User attributes schema
- Password policies
- MFA configuration
- Lambda triggers (pre-signup, post-confirmation, etc.)
- Domain configuration for hosted UI

### API Gateway Module
Deploys REST API with:
- Cognito authorizer integration
- CORS configuration
- Request/response models
- Deployment stages
- CloudWatch logging

### Lambda Module
Provisions Lambda functions for:
- User profile management
- Protected resource access
- Custom authentication flows
- Post-authentication processing

### IAM Module
Defines least-privilege policies for:
- Lambda execution roles
- API Gateway invoke permissions
- Cognito service permissions

### Migration Considerations

To adapt this to other cloud providers:
- **Azure**: Replace Cognito → Azure AD B2C, API Gateway → Azure API Management
- **GCP**: Replace Cognito → Firebase Auth/Identity Platform, API Gateway → Cloud Endpoints
- **Multi-cloud**: Abstract authentication with standards-based approach

##  Usage Examples

### User Registration

```bash
# Register a new user
aws cognito-idp sign-up \
  --client-id <CLIENT_ID> \
  --username user@example.com \
  --password "SecureP@ssw0rd!" \
  --user-attributes Name=email,Value=user@example.com
```

### User Authentication

```bash
# Authenticate and receive tokens
aws cognito-idp initiate-auth \
  --client-id <CLIENT_ID> \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=user@example.com,PASSWORD="SecureP@ssw0rd!"
```

### API Access

```bash
# Call protected API endpoint
curl -H "Authorization: Bearer <ID_TOKEN>" \
  https://<API_ID>.execute-api.<REGION>.amazonaws.com/dev/profile
```

##  Testing

```bash
# Run validation tests
cd scripts
./test-authentication.sh

# Test MFA flow
./test-mfa.sh

# Load testing
./load-test.sh
```

##  Monitoring & Logging

- CloudWatch Logs for Lambda functions
- API Gateway access logs
- Cognito user pool analytics
- Custom metrics for authentication events
- Alarms for security events

## Resources

- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [API Gateway Authorizers](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [OAuth 2.0 & OIDC Specifications](https://oauth.net/2/)
