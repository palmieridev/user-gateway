#!/bin/bash
# Deployment script for different environments

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display usage
usage() {
    echo "Usage: $0 [environment] [action]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Actions:"
    echo "  plan      - Show execution plan"
    echo "  apply     - Apply changes"
    echo "  destroy   - Destroy infrastructure"
    echo "  output    - Show outputs"
    echo ""
    echo "Example: $0 dev plan"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

ENVIRONMENT=$1
ACTION=$2

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
    usage
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy|output)$ ]]; then
    echo -e "${RED}Error: Invalid action '$ACTION'${NC}"
    usage
fi

# Navigate to environment directory
ENV_DIR="../environments/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}Error: Environment directory not found: $ENV_DIR${NC}"
    exit 1
fi

cd "$ENV_DIR"

echo -e "${BLUE}=== Secure IAM Deployment ===${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Action: ${YELLOW}$ACTION${NC}"
echo ""

# Production warning
if [ "$ENVIRONMENT" == "prod" ]; then
    echo -e "${RED}⚠️  WARNING: You are about to modify PRODUCTION infrastructure${NC}"
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
    echo ""
fi

# Execute action
case $ACTION in
    plan)
        echo -e "${BLUE}Creating execution plan...${NC}"
        terraform plan
        ;;
    apply)
        echo -e "${BLUE}Applying changes...${NC}"
        terraform apply
        echo ""
        echo -e "${GREEN}✓ Deployment completed${NC}"
        echo ""
        echo -e "${BLUE}Outputs:${NC}"
        terraform output
        ;;
    destroy)
        echo -e "${RED}⚠️  WARNING: This will destroy all infrastructure${NC}"
        read -p "Type 'destroy' to confirm: " CONFIRM
        if [ "$CONFIRM" != "destroy" ]; then
            echo "Aborted."
            exit 0
        fi
        terraform destroy
        echo -e "${GREEN}✓ Infrastructure destroyed${NC}"
        ;;
    output)
        terraform output
        ;;
esac
