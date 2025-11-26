#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ROLE_NAME="gift-exchange-lambda-role"

echo -e "${YELLOW}Tearing down IAM role: ${ROLE_NAME}${NC}"

# Check if role exists
if ! aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
    echo -e "${YELLOW}Role ${ROLE_NAME} does not exist. Nothing to delete.${NC}"
    exit 0
fi

# Detach policies
echo -e "${YELLOW}Detaching policies...${NC}"

# Detach Lambda basic execution policy
aws iam detach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null

# Delete inline DynamoDB policy
aws iam delete-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "DynamoDBAccess" 2>/dev/null

# Delete the role
echo -e "${YELLOW}Deleting IAM role...${NC}"
aws iam delete-role --role-name "$ROLE_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ IAM role ${ROLE_NAME} deleted successfully${NC}"
else
    echo -e "${RED}✗ Failed to delete IAM role (may be in use by Lambda functions)${NC}"
    exit 1
fi

