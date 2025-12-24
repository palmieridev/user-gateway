#!/bin/bash
# Test script for MFA enrollment and authentication

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== MFA Enrollment Test ===${NC}\n"

# Check for required tools
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

# Get configuration
echo -e "${BLUE}Fetching configuration...${NC}"
cd ../environments/staging

if [ ! -f terraform.tfstate ]; then
    echo -e "${RED}Error: No terraform state found. Deploy staging environment first${NC}"
    exit 1
fi

USER_POOL_ID=$(terraform output -raw cognito_user_pool_id 2>/dev/null || echo "")
CLIENT_ID=$(terraform output -raw cognito_client_id 2>/dev/null || echo "")
REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")

if [ -z "$USER_POOL_ID" ] || [ -z "$CLIENT_ID" ]; then
    echo -e "${RED}Error: Could not retrieve configuration${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration retrieved${NC}\n"

TEST_EMAIL="mfa-test-$(date +%s)@example.com"
TEST_PASSWORD="TestPassword123!@#"

echo -e "${BLUE}Step 1: Creating test user${NC}"
aws cognito-idp sign-up \
    --region "$REGION" \
    --client-id "$CLIENT_ID" \
    --username "$TEST_EMAIL" \
    --password "$TEST_PASSWORD" \
    --user-attributes Name=email,Value="$TEST_EMAIL" Name=name,Value="MFA Test User" \
    &> /dev/null

echo -e "${GREEN}✓ User created${NC}\n"

echo -e "${BLUE}Step 2: Confirming user${NC}"
aws cognito-idp admin-confirm-sign-up \
    --region "$REGION" \
    --user-pool-id "$USER_POOL_ID" \
    --username "$TEST_EMAIL" &> /dev/null

echo -e "${GREEN}✓ User confirmed${NC}\n"

echo -e "${BLUE}Step 3: Authenticating user${NC}"
AUTH_RESULT=$(aws cognito-idp initiate-auth \
    --region "$REGION" \
    --client-id "$CLIENT_ID" \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME="$TEST_EMAIL",PASSWORD="$TEST_PASSWORD")

SESSION=$(echo "$AUTH_RESULT" | jq -r '.Session // empty')

if [ -n "$SESSION" ]; then
    echo -e "${YELLOW}⚠ MFA setup required${NC}"
    echo -e "${BLUE}Step 4: Setting up TOTP MFA${NC}"
    
    ASSOCIATE_RESULT=$(aws cognito-idp associate-software-token \
        --region "$REGION" \
        --session "$SESSION")
    
    SECRET_CODE=$(echo "$ASSOCIATE_RESULT" | jq -r '.SecretCode')
    NEW_SESSION=$(echo "$ASSOCIATE_RESULT" | jq -r '.Session')
    
    echo -e "${GREEN}✓ TOTP secret generated${NC}"
    echo -e "${YELLOW}Note: In a real application, display this as a QR code${NC}"
    echo "  Secret: $SECRET_CODE"
else
    echo -e "${GREEN}✓ Authentication successful (MFA not required)${NC}"
fi

echo ""

# Cleanup
echo -e "${BLUE}Step 5: Cleaning up${NC}"
aws cognito-idp admin-delete-user \
    --region "$REGION" \
    --user-pool-id "$USER_POOL_ID" \
    --username "$TEST_EMAIL" &> /dev/null

echo -e "${GREEN}✓ Test completed${NC}"
