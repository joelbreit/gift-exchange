#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REGION="us-east-1"

echo -e "${YELLOW}Tearing down Lambda functions${NC}"

# Function to delete a Lambda function
delete_function() {
    local function_name=$1
    
    if aws lambda get-function --function-name "$function_name" --region "$REGION" &>/dev/null; then
        echo -e "${YELLOW}Deleting function ${function_name}...${NC}"
        aws lambda delete-function --function-name "$function_name" --region "$REGION"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Function ${function_name} deleted${NC}"
        else
            echo -e "${RED}✗ Failed to delete function ${function_name}${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Function ${function_name} does not exist. Skipping.${NC}"
    fi
    
    return 0
}

# Delete all functions
delete_function "createAccount"
delete_function "updatePassword"
delete_function "updateEmail"
delete_function "deleteAccount"

echo -e "${GREEN}✓ Lambda teardown completed${NC}"

