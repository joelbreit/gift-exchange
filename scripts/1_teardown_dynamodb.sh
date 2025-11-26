#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TABLE_NAME="gift-exchange-accounts"
REGION="us-east-1"

echo -e "${YELLOW}Tearing down DynamoDB table: ${TABLE_NAME}${NC}"

# Check if table exists
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &>/dev/null; then
    echo -e "${YELLOW}Table ${TABLE_NAME} does not exist. Nothing to delete.${NC}"
    exit 0
fi

# Delete the table
echo -e "${YELLOW}Deleting DynamoDB table...${NC}"
aws dynamodb delete-table \
    --table-name "$TABLE_NAME" \
    --region "$REGION"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ DynamoDB table ${TABLE_NAME} deletion initiated${NC}"
    echo -e "${YELLOW}Waiting for table to be deleted...${NC}"
    aws dynamodb wait table-not-exists --table-name "$TABLE_NAME" --region "$REGION"
    echo -e "${GREEN}✓ Table has been deleted${NC}"
else
    echo -e "${RED}✗ Failed to delete DynamoDB table${NC}"
    exit 1
fi

