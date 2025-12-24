# Deployment Guide

This guide provides step-by-step instructions for deploying the Secure IAM infrastructure.

## Prerequisites

- [x] AWS Account with Administrator access
- [x] Terraform >= 1.0 installed
- [x] AWS CLI configured (`aws configure`)
- [x] Git installed
- [x] (Optional) jq for testing scripts

## Quick Start

### 1. Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd user-gateway-cognito-apigateway

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

### 2. Deploy Development Environment

```bash
cd environments/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the outputs
terraform output
```

### 3. Test the Deployment

```bash
# Run authentication tests
cd ../../scripts
./test-authentication.sh
```

## Detailed Deployment Steps

### Development Environment

**Purpose**: Local development and testing

```bash
cd environments/dev

# Initialize
terraform init

# Plan (review changes)
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Get outputs
terraform output -json > outputs.json
```

**Configuration**:
- MFA: Disabled (for convenience)
- Advanced Security: Disabled (cost savings)
- Throttling: Low limits

### Staging Environment

**Purpose**: Pre-production testing with production-like settings

```bash
cd environments/staging

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Test MFA
cd ../../scripts
./test-mfa.sh
```

**Configuration**:
- MFA: Enabled
- Advanced Security: Enabled
- Throttling: Medium limits

### Production Environment

**Purpose**: Production workloads

```bash
cd environments/prod

# Initialize with remote backend
terraform init

# Plan
terraform plan -out=tfplan

# Review plan carefully!
# Apply (requires confirmation)
terraform apply tfplan
```

**Configuration**:
- MFA: Required
- Advanced Security: Enforced
- Throttling: High limits
- Monitoring: Full

## Post-Deployment

### 1. Verify Resources

```bash
# Check Cognito User Pool
aws cognito-idp describe-user-pool \
  --user-pool-id <USER_POOL_ID>

# Check API Gateway
aws apigateway get-rest-api \
  --rest-api-id <API_ID>

# Check Lambda function
aws lambda get-function \
  --function-name <FUNCTION_NAME>
```

### 2. Test Authentication Flow

```bash
# Run comprehensive tests
cd scripts
./test-authentication.sh
```

### 3. Monitor Resources

```bash
# View CloudWatch logs
aws logs tail /aws/lambda/<FUNCTION_NAME> --follow

# View API Gateway logs
aws logs tail /aws/apigateway/<PROJECT>-<ENV> --follow
```

## Environment Variables

Set these before deployment:

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
export TF_VAR_project_name=user-gateway
```

## Custom Domain (Optional)

To configure a custom domain for API Gateway:

1. **Register Certificate** (ACM):
```bash
aws acm request-certificate \
  --domain-name api.yourdomain.com \
  --validation-method DNS
```

2. **Update API Gateway Module**:
```hcl
# In modules/api-gateway/main.tf
resource "aws_api_gateway_domain_name" "custom" {
  domain_name              = "api.yourdomain.com"
  certificate_arn          = var.certificate_arn
  security_policy          = "TLS_1_2"
}
```

3. **Create DNS Record** (Route 53):
```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <ZONE_ID> \
  --change-batch file://dns-record.json
```

## Troubleshooting

### Common Issues

**Issue**: `Error: No credentials found`
```bash
# Solution: Configure AWS CLI
aws configure
```

**Issue**: `Error: Backend initialization required`
```bash
# Solution: Initialize Terraform
terraform init
```

**Issue**: `Error: State lock timeout`
```bash
# Solution: Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

**Issue**: Lambda deployment package too large
```bash
# Solution: Use Lambda layers
# See modules/lambda/README.md
```

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Check for security issues
tfsec .

# Plan with detailed logging
TF_LOG=DEBUG terraform plan
```

## Rollback Procedure

If deployment fails:

```bash
# 1. Review the error
terraform show

# 2. Destroy problematic resources
terraform destroy -target=module.api_gateway

# 3. Fix the issue

# 4. Re-apply
terraform apply
```

## CI/CD Integration

### GitHub Actions

The repository includes GitHub Actions workflows:

- `.github/workflows/terraform-validation.yml`: Validates on PR
- `.github/workflows/security-scan.yml`: Security scanning

### GitLab CI

Example `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - plan
  - apply

validate:
  stage: validate
  script:
    - terraform init -backend=false
    - terraform validate
    - terraform fmt -check

plan:
  stage: plan
  script:
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan

apply:
  stage: apply
  script:
    - terraform apply tfplan
  when: manual
  only:
    - main
```

## Cost Estimation

Expected monthly costs (us-east-1):

| Service | Dev | Staging | Prod |
|---------|-----|---------|------|
| Cognito | $0 (free tier) | $0-10 | $50+ |
| API Gateway | $0-5 | $10-20 | $50+ |
| Lambda | $0 (free tier) | $0-5 | $10+ |
| CloudWatch | $0-2 | $5-10 | $20+ |
| **Total** | **$0-7** | **$15-45** | **$130+** |

Use [AWS Pricing Calculator](https://calculator.aws/) for accurate estimates.

## Security Checklist

Before deploying to production:

- [ ] MFA enabled on User Pool
- [ ] Advanced security features enabled
- [ ] Strong password policies configured
- [ ] API Gateway authorizer configured
- [ ] CloudWatch logging enabled
- [ ] X-Ray tracing enabled
- [ ] Secrets in AWS Secrets Manager
- [ ] Remote state backend configured
- [ ] State encryption enabled
- [ ] CORS properly configured
- [ ] Rate limiting configured
- [ ] IAM policies follow least privilege
- [ ] All resources tagged properly
- [ ] Monitoring alarms configured

## Next Steps

After successful deployment:

1. **Configure Monitoring**: Set up CloudWatch dashboards
2. **Enable Alarms**: Create alerts for security events
3. **Document APIs**: Update API documentation
4. **Load Testing**: Perform load tests
5. **Disaster Recovery**: Test backup/restore procedures
6. **Security Audit**: Run security scans
7. **Cost Optimization**: Review and optimize costs

## Support

For issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review module-specific READMEs
- Open an issue on GitHub
- Consult AWS documentation

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [Lambda Documentation](https://docs.aws.amazon.com/lambda/)
