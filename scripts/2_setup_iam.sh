#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ROLE_NAME="gift-exchange-lambda-role"
TABLE_NAME="gift-exchange-accounts"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${YELLOW}Setting up IAM role: ${ROLE_NAME}${NC}"

# Check if role already exists
if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
    echo -e "${YELLOW}Role ${ROLE_NAME} already exists. Skipping creation.${NC}"
else
    # Create trust policy for Lambda
    echo -e "${YELLOW}Creating IAM role...${NC}"
    cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json

    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create IAM role${NC}"
        rm -f /tmp/trust-policy.json
        exit 1
    fi

    echo -e "${GREEN}✓ IAM role ${ROLE_NAME} created successfully${NC}"
    rm -f /tmp/trust-policy.json
fi

# Attach basic Lambda execution policy
echo -e "${YELLOW}Attaching Lambda basic execution policy...${NC}"
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Lambda basic execution policy attached${NC}"
else
    echo -e "${YELLOW}Policy may already be attached (continuing...)${NC}"
fi

# Create and attach DynamoDB policy
echo -e "${YELLOW}Creating DynamoDB access policy...${NC}"
cat > /tmp/dynamodb-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:${REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
    }
  ]
}
EOF

aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "DynamoDBAccess" \
    --policy-document file:///tmp/dynamodb-policy.json

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ DynamoDB access policy attached${NC}"
else
    echo -e "${RED}✗ Failed to attach DynamoDB policy${NC}"
    rm -f /tmp/dynamodb-policy.json
    exit 1
fi

rm -f /tmp/dynamodb-policy.json

# Wait a moment for IAM to propagate
echo -e "${YELLOW}Waiting for IAM changes to propagate...${NC}"
sleep 3

echo -e "${GREEN}✓ IAM setup completed successfully${NC}"

