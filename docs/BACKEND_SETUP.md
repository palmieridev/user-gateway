# Backend Configuration Guide

This guide explains how to set up remote state management for Terraform using AWS S3 and DynamoDB.

## Why Remote State?

Remote state provides:
- **Team Collaboration**: Multiple team members can work safely
- **State Locking**: Prevents concurrent modifications
- **Encryption**: State is encrypted at rest
- **Versioning**: Track state changes over time
- **Disaster Recovery**: State is backed up automatically

## Prerequisites

1. AWS Account with appropriate permissions
2. S3 bucket for state storage
3. DynamoDB table for state locking
4. AWS CLI configured

## Setup Steps

### 1. Create S3 Bucket

```bash
# Set your bucket name (must be globally unique)
BUCKET_NAME="your-company-terraform-state"
REGION="us-east-1"

# Create the bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
    IgnorePublicAcls=true,\
    BlockPublicPolicy=true,\
    RestrictPublicBuckets=true
```

### 2. Create DynamoDB Table

```bash
# Create table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION
```

### 3. Configure Backend

Update the backend configuration in each environment:

**environments/dev/main.tf**:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-company-terraform-state"
    key            = "user-gateway/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 4. Initialize Backend

```bash
cd environments/dev
terraform init
```

You'll be prompted to migrate existing state if any exists.

## Security Considerations

### S3 Bucket Policy

Apply a bucket policy to restrict access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::your-bucket-name/*",
        "arn:aws:s3:::your-bucket-name"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

### IAM Permissions

Required IAM permissions for Terraform execution:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

## Multi-Environment Setup

For different environments, use different state keys:

- Dev: `user-gateway/dev/terraform.tfstate`
- Staging: `user-gateway/staging/terraform.tfstate`
- Prod: `user-gateway/prod/terraform.tfstate`

## Terraform Cloud Alternative

Instead of S3/DynamoDB, you can use Terraform Cloud:

```hcl
terraform {
  cloud {
    organization = "your-organization"
    
    workspaces {
      name = "user-gateway-dev"
    }
  }
}
```

## Troubleshooting

### State Lock Issues

If a lock persists after a failed run:

```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### State Corruption

If state becomes corrupted:

1. Download the last known good version from S3
2. Restore it locally
3. Re-initialize Terraform

## Best Practices

1. **Never commit state files** to version control
2. **Enable versioning** on the S3 bucket
3. **Use separate buckets** for different environments (optional)
4. **Encrypt state** at rest and in transit
5. **Restrict access** using IAM policies
6. **Regular backups** of state files
7. **Test state recovery** procedures

## Migration from Local to Remote

```bash
# 1. Configure backend in Terraform files
# 2. Run init with migrate flag
terraform init -migrate-state

# 3. Verify state is in S3
aws s3 ls s3://your-bucket-name/user-gateway/dev/

# 4. Delete local state files (after verification)
rm terraform.tfstate*
```

## Cost Estimation

- **S3**: ~$0.023/GB/month + request costs
- **DynamoDB**: $0.25/month for 5 RCU/WCU (very low traffic)
- **Total**: < $1/month for typical usage

## References

- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [State Locking](https://www.terraform.io/docs/language/state/locking.html)
