#!/bin/bash
# Test script for user authentication flow

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Secure IAM Authentication Test ===${NC}\n"

# Check for required tools
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed${NC}"
    exit 1
fi

# Get configuration from Terraform outputs
echo -e "${BLUE}Fetching configuration...${NC}"
cd ../environments/dev

if [ ! -f terraform.tfstate ]; then
    echo -e "${RED}Error: No terraform state found. Please run 'terraform apply' first${NC}"
    exit 1
fi

USER_POOL_ID=$(terraform output -raw cognito_user_pool_id 2>/dev/null || echo "")
CLIENT_ID=$(terraform output -raw cognito_client_id 2>/dev/null || echo "")
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")

if [ -z "$USER_POOL_ID" ] || [ -z "$CLIENT_ID" ] || [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not retrieve necessary configuration from Terraform${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration retrieved${NC}"
echo "  User Pool ID: $USER_POOL_ID"
echo "  Client ID: $CLIENT_ID"
echo "  API URL: $API_URL"
echo ""

# Test variables
TEST_EMAIL="test-user-$(date +%s)@example.com"
TEST_PASSWORD="TestPassword123!@#"
TEST_NAME="Test User"

echo -e "${BLUE}Step 1: Registering new user${NC}"
echo "  Email: $TEST_EMAIL"

SIGNUP_RESULT=$(aws cognito-idp sign-up \
    --region "$REGION" \
    --client-id "$CLIENT_ID" \
    --username "$TEST_EMAIL" \
    --password "$TEST_PASSWORD" \
    --user-attributes Name=email,Value="$TEST_EMAIL" Name=name,Value="$TEST_NAME" \
    2>&1) || {
    echo -e "${RED}✗ Sign up failed${NC}"
    echo "$SIGNUP_RESULT"
    exit 1
}

echo -e "${GREEN}✓ User registered successfully${NC}\n"

# Admin confirm user (skip email verification for testing)
echo -e "${BLUE}Step 2: Confirming user (admin)${NC}"
aws cognito-idp admin-confirm-sign-up \
    --region "$REGION" \
    --user-pool-id "$USER_POOL_ID" \
    --username "$TEST_EMAIL" &> /dev/null || {
    echo -e "${RED}✗ User confirmation failed${NC}"
    exit 1
}

echo -e "${GREEN}✓ User confirmed${NC}\n"

# Authenticate user
echo -e "${BLUE}Step 3: Authenticating user${NC}"
AUTH_RESULT=$(aws cognito-idp initiate-auth \
    --region "$REGION" \
    --client-id "$CLIENT_ID" \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME="$TEST_EMAIL",PASSWORD="$TEST_PASSWORD" \
    2>&1) || {
    echo -e "${RED}✗ Authentication failed${NC}"
    echo "$AUTH_RESULT"
    exit 1
}

ID_TOKEN=$(echo "$AUTH_RESULT" | jq -r '.AuthenticationResult.IdToken')
ACCESS_TOKEN=$(echo "$AUTH_RESULT" | jq -r '.AuthenticationResult.AccessToken')

if [ -z "$ID_TOKEN" ] || [ "$ID_TOKEN" == "null" ]; then
    echo -e "${RED}✗ No ID token received${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Authentication successful${NC}"
echo "  ID Token: ${ID_TOKEN:0:50}..."
echo ""

# Test API endpoints
echo -e "${BLUE}Step 4: Testing API endpoints${NC}\n"

# Test health endpoint (public)
echo -e "${BLUE}  Testing GET /health (public)${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/health")
HEALTH_CODE=$(echo "$HEALTH_RESPONSE" | tail -n 1)
HEALTH_BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HEALTH_CODE" == "200" ]; then
    echo -e "${GREEN}  ✓ Health check passed${NC}"
    echo "    Response: $HEALTH_BODY"
else
    echo -e "${RED}  ✗ Health check failed (HTTP $HEALTH_CODE)${NC}"
fi
echo ""

# Test GET /profile (protected)
echo -e "${BLUE}  Testing GET /profile (protected)${NC}"
PROFILE_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $ID_TOKEN" \
    "$API_URL/profile")
PROFILE_CODE=$(echo "$PROFILE_RESPONSE" | tail -n 1)
PROFILE_BODY=$(echo "$PROFILE_RESPONSE" | head -n -1)

if [ "$PROFILE_CODE" == "200" ]; then
    echo -e "${GREEN}  ✓ GET /profile successful${NC}"
    echo "    Response: $PROFILE_BODY" | jq '.' 2>/dev/null || echo "    Response: $PROFILE_BODY"
else
    echo -e "${RED}  ✗ GET /profile failed (HTTP $PROFILE_CODE)${NC}"
    echo "    Response: $PROFILE_BODY"
fi
echo ""

# Test PUT /profile (protected)
echo -e "${BLUE}  Testing PUT /profile (protected)${NC}"
UPDATE_DATA='{"preferences": {"theme": "dark", "notifications": true}}'
PUT_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X PUT \
    -H "Authorization: Bearer $ID_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$UPDATE_DATA" \
    "$API_URL/profile")
PUT_CODE=$(echo "$PUT_RESPONSE" | tail -n 1)
PUT_BODY=$(echo "$PUT_RESPONSE" | head -n -1)

if [ "$PUT_CODE" == "200" ]; then
    echo -e "${GREEN}  ✓ PUT /profile successful${NC}"
    echo "    Response: $PUT_BODY" | jq '.' 2>/dev/null || echo "    Response: $PUT_BODY"
else
    echo -e "${RED}  ✗ PUT /profile failed (HTTP $PUT_CODE)${NC}"
    echo "    Response: $PUT_BODY"
fi
echo ""

# Test unauthorized access
echo -e "${BLUE}  Testing unauthorized access${NC}"
UNAUTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/profile")
UNAUTH_CODE=$(echo "$UNAUTH_RESPONSE" | tail -n 1)

if [ "$UNAUTH_CODE" == "401" ]; then
    echo -e "${GREEN}  ✓ Unauthorized access correctly rejected${NC}"
else
    echo -e "${RED}  ✗ Unexpected response for unauthorized access (HTTP $UNAUTH_CODE)${NC}"
fi
echo ""

# Cleanup
echo -e "${BLUE}Step 5: Cleaning up test user${NC}"
aws cognito-idp admin-delete-user \
    --region "$REGION" \
    --user-pool-id "$USER_POOL_ID" \
    --username "$TEST_EMAIL" &> /dev/null || {
    echo -e "${RED}✗ Cleanup failed${NC}"
}

echo -e "${GREEN}✓ Test user deleted${NC}\n"

echo -e "${GREEN}=== All tests completed ===${NC}"
