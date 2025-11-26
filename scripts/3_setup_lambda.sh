#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ROLE_NAME="gift-exchange-lambda-role"
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text 2>/dev/null)
REGION="us-east-1"
TABLE_NAME="gift-exchange-accounts"
FUNCTIONS_DIR="functions"

if [ -z "$ROLE_ARN" ]; then
    echo -e "${RED}✗ IAM role ${ROLE_NAME} not found. Please run 2_setup_iam.sh first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Setting up Lambda functions${NC}"

# Function to deploy a Lambda function
deploy_function() {
    local function_name=$1
    local function_dir="${FUNCTIONS_DIR}/${function_name}"
    
    if [ ! -d "$function_dir" ]; then
        echo -e "${RED}✗ Function directory ${function_dir} not found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Deploying ${function_name}...${NC}"
    
    # Navigate to function directory
    cd "$function_dir" || return 1
    
    # Install dependencies
    if [ -f "package.json" ]; then
        echo -e "${YELLOW}Installing dependencies for ${function_name}...${NC}"
        npm install --production --silent
    fi
    
    # Create deployment package
    echo -e "${YELLOW}Creating deployment package for ${function_name}...${NC}"
    zip -r "/tmp/${function_name}.zip" . -q
    
    # Check if function exists
    if aws lambda get-function --function-name "$function_name" --region "$REGION" &>/dev/null; then
        echo -e "${YELLOW}Function ${function_name} already exists. Updating...${NC}"
        aws lambda update-function-code \
            --function-name "$function_name" \
            --zip-file "fileb:///tmp/${function_name}.zip" \
            --region "$REGION" > /dev/null
        
        # Update configuration
        aws lambda update-function-configuration \
            --function-name "$function_name" \
            --role "$ROLE_ARN" \
            --environment "Variables={ACCOUNTS_TABLE_NAME=${TABLE_NAME}}" \
            --region "$REGION" > /dev/null
        
        echo -e "${GREEN}✓ Function ${function_name} updated${NC}"
    else
        echo -e "${YELLOW}Creating function ${function_name}...${NC}"
        aws lambda create-function \
            --function-name "$function_name" \
            --runtime nodejs20.x \
            --role "$ROLE_ARN" \
            --handler index.handler \
            --zip-file "fileb:///tmp/${function_name}.zip" \
            --environment "Variables={ACCOUNTS_TABLE_NAME=${TABLE_NAME}}" \
            --region "$REGION" > /dev/null
        
        echo -e "${GREEN}✓ Function ${function_name} created${NC}"
    fi
    
    # Clean up
    rm -f "/tmp/${function_name}.zip"
    cd - > /dev/null || return 1
    
    return 0
}

# Deploy all functions
cd "$(dirname "$0")/.." || exit 1

deploy_function "createAccount" || exit 1
deploy_function "updatePassword" || exit 1
deploy_function "updateEmail" || exit 1
deploy_function "deleteAccount" || exit 1

echo -e "${GREEN}✓ All Lambda functions deployed successfully${NC}"

