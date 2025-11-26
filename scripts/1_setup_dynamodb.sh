#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TABLE_NAME="gift-exchange-accounts"
REGION="us-east-1"

echo -e "${YELLOW}Setting up DynamoDB table: ${TABLE_NAME}${NC}"

# Check if table already exists
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &>/dev/null; then
    echo -e "${YELLOW}Table ${TABLE_NAME} already exists. Skipping creation.${NC}"
    exit 0
fi

# Create the table
echo -e "${YELLOW}Creating DynamoDB table...${NC}"
aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ DynamoDB table ${TABLE_NAME} created successfully${NC}"
    echo -e "${YELLOW}Waiting for table to be active...${NC}"
    aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"
    echo -e "${GREEN}✓ Table is now active${NC}"
else
    echo -e "${RED}✗ Failed to create DynamoDB table${NC}"
    exit 1
fi

