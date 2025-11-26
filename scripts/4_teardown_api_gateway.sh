#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_NAME="gift-exchange-api"
REGION="us-east-1"

echo -e "${YELLOW}Tearing down API Gateway: ${API_NAME}${NC}"

# Get API ID
API_ID=$(aws apigateway get-rest-apis --region "$REGION" --query "items[?name=='${API_NAME}'].id" --output text 2>/dev/null)

if [ -z "$API_ID" ] || [ "$API_ID" == "None" ]; then
    echo -e "${YELLOW}API ${API_NAME} does not exist. Nothing to delete.${NC}"
    exit 0
fi

echo -e "${YELLOW}Deleting REST API: ${API_ID}...${NC}"
aws apigateway delete-rest-api \
    --rest-api-id "$API_ID" \
    --region "$REGION"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ REST API ${API_NAME} deleted successfully${NC}"
else
    echo -e "${RED}✗ Failed to delete REST API${NC}"
    exit 1
fi

echo -e "${GREEN}✓ API Gateway teardown completed${NC}"

