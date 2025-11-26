#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_NAME="gift-exchange-api"
REGION="us-east-1"
STAGE_NAME="dev"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${YELLOW}Setting up API Gateway: ${API_NAME}${NC}"

# Get Lambda function ARNs
CREATE_ACCOUNT_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:createAccount"
UPDATE_PASSWORD_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:updatePassword"
UPDATE_EMAIL_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:updateEmail"
DELETE_ACCOUNT_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:deleteAccount"

# Check if API already exists
API_ID=$(aws apigateway get-rest-apis --region "$REGION" --query "items[?name=='${API_NAME}'].id" --output text 2>/dev/null)

if [ -z "$API_ID" ] || [ "$API_ID" == "None" ]; then
    echo -e "${YELLOW}Creating REST API...${NC}"
    API_ID=$(aws apigateway create-rest-api \
        --name "$API_NAME" \
        --description "Gift Exchange API" \
        --region "$REGION" \
        --query 'id' \
        --output text)
    
    if [ -z "$API_ID" ]; then
        echo -e "${RED}✗ Failed to create REST API${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ REST API created with ID: ${API_ID}${NC}"
else
    echo -e "${YELLOW}REST API already exists with ID: ${API_ID}${NC}"
fi

# Get root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
    --rest-api-id "$API_ID" \
    --region "$REGION" \
    --query 'items[?path==`/`].id' \
    --output text)

if [ -z "$ROOT_RESOURCE_ID" ]; then
    echo -e "${RED}✗ Failed to get root resource ID${NC}"
    exit 1
fi

# Function to create resource if it doesn't exist
create_resource() {
    local parent_id=$1
    local path_part=$2
    local resource_name=$3
    
    # Check if resource already exists by path
    local existing_id=$(aws apigateway get-resources \
        --rest-api-id "$API_ID" \
        --region "$REGION" \
        --query "items[?pathPart=='${path_part}'].id" \
        --output text 2>/dev/null | head -n1)
    
    if [ -n "$existing_id" ] && [ "$existing_id" != "None" ]; then
        echo -e "${YELLOW}Resource ${resource_name} already exists${NC}"
        echo "$existing_id"
        return 0
    fi
    
    echo -e "${YELLOW}Creating resource: ${resource_name}${NC}"
    local resource_id=$(aws apigateway create-resource \
        --rest-api-id "$API_ID" \
        --parent-id "$parent_id" \
        --path-part "$path_part" \
        --region "$REGION" \
        --query 'id' \
        --output text)
    
    if [ -z "$resource_id" ] || [ "$resource_id" == "None" ]; then
        echo -e "${RED}✗ Failed to create resource ${resource_name}${NC}"
        exit 1
    fi
    
    # Small delay to ensure resource is available
    sleep 1
    
    echo -e "${GREEN}✓ Resource ${resource_name} created${NC}"
    echo "$resource_id"
}

# Function to get resource ID by path
get_resource_by_path() {
    local path=$1
    local resource_id=$(aws apigateway get-resources \
        --rest-api-id "$API_ID" \
        --region "$REGION" \
        --query "items[?path=='${path}'].id" \
        --output text 2>/dev/null | head -n1)
    echo "$resource_id"
}

# Function to create method and Lambda integration
create_method_integration() {
    local resource_id=$1
    local http_method=$2
    local lambda_arn=$3
    local function_name=$4
    
    echo -e "${YELLOW}Creating ${http_method} method for ${function_name}...${NC}"
    
    # Create method
    aws apigateway put-method \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method" \
        --authorization-type "NONE" \
        --region "$REGION" > /dev/null 2>&1
    
    # Create Lambda integration
    aws apigateway put-integration \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method" \
        --type AWS_PROXY \
        --integration-http-method POST \
        --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${lambda_arn}/invocations" \
        --region "$REGION" > /dev/null 2>&1
    
    # Grant API Gateway permission to invoke Lambda
    aws lambda add-permission \
        --function-name "$function_name" \
        --statement-id "apigateway-${API_ID}-${resource_id}-${http_method}" \
        --action lambda:InvokeFunction \
        --principal apigateway.amazonaws.com \
        --source-arn "arn:aws:execute-api:${REGION}:${ACCOUNT_ID}:${API_ID}/*/${http_method}/*" \
        --region "$REGION" > /dev/null 2>&1
    
    echo -e "${GREEN}✓ ${http_method} method created for ${function_name}${NC}"
}

# Function to enable CORS
enable_cors() {
    local resource_id=$1
    local http_method=$2
    
    echo -e "${YELLOW}Enabling CORS for ${http_method}...${NC}"
    
    # Create OPTIONS method for CORS
    aws apigateway put-method \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method OPTIONS \
        --authorization-type NONE \
        --region "$REGION" > /dev/null 2>&1
    
    # Create mock integration for OPTIONS
    aws apigateway put-integration \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method OPTIONS \
        --type MOCK \
        --request-templates '{"application/json":"{\"statusCode\":200}"}' \
        --region "$REGION" > /dev/null 2>&1
    
    # Create method response for OPTIONS
    aws apigateway put-method-response \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method OPTIONS \
        --status-code 200 \
        --response-parameters '{"method.response.header.Access-Control-Allow-Headers":true,"method.response.header.Access-Control-Allow-Methods":true,"method.response.header.Access-Control-Allow-Origin":true}' \
        --region "$REGION" > /dev/null 2>&1
    
    # Create integration response for OPTIONS
    aws apigateway put-integration-response \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method OPTIONS \
        --status-code 200 \
        --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'GET,POST,PUT,DELETE,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' \
        --region "$REGION" > /dev/null 2>&1
    
    echo -e "${GREEN}✓ CORS enabled for ${http_method}${NC}"
}

# Create /accounts resource
ACCOUNTS_RESOURCE_ID=$(create_resource "$ROOT_RESOURCE_ID" "accounts" "/accounts")

# Verify and get the actual resource ID
ACCOUNTS_RESOURCE_ID=$(get_resource_by_path "/accounts")
if [ -z "$ACCOUNTS_RESOURCE_ID" ]; then
    echo -e "${RED}✗ Failed to get /accounts resource ID${NC}"
    exit 1
fi

# Create POST /accounts method
create_method_integration "$ACCOUNTS_RESOURCE_ID" "POST" "$CREATE_ACCOUNT_ARN" "createAccount"
enable_cors "$ACCOUNTS_RESOURCE_ID" "POST"

# Create /accounts/{id} resource
ACCOUNTS_ID_RESOURCE_ID=$(create_resource "$ACCOUNTS_RESOURCE_ID" "{id}" "/accounts/{id}")

# Verify and get the actual resource ID
ACCOUNTS_ID_RESOURCE_ID=$(get_resource_by_path "/accounts/{id}")
if [ -z "$ACCOUNTS_ID_RESOURCE_ID" ]; then
    echo -e "${RED}✗ Failed to get /accounts/{id} resource ID${NC}"
    exit 1
fi

# Create DELETE /accounts/{id} method
create_method_integration "$ACCOUNTS_ID_RESOURCE_ID" "DELETE" "$DELETE_ACCOUNT_ARN" "deleteAccount"
enable_cors "$ACCOUNTS_ID_RESOURCE_ID" "DELETE"

# Create /accounts/{id}/password resource
PASSWORD_RESOURCE_ID=$(create_resource "$ACCOUNTS_ID_RESOURCE_ID" "password" "/accounts/{id}/password")

# Verify and get the actual resource ID
PASSWORD_RESOURCE_ID=$(get_resource_by_path "/accounts/{id}/password")
if [ -z "$PASSWORD_RESOURCE_ID" ]; then
    echo -e "${RED}✗ Failed to get /accounts/{id}/password resource ID${NC}"
    exit 1
fi

# Create PUT /accounts/{id}/password method
create_method_integration "$PASSWORD_RESOURCE_ID" "PUT" "$UPDATE_PASSWORD_ARN" "updatePassword"
enable_cors "$PASSWORD_RESOURCE_ID" "PUT"

# Create /accounts/{id}/email resource
EMAIL_RESOURCE_ID=$(create_resource "$ACCOUNTS_ID_RESOURCE_ID" "email" "/accounts/{id}/email")

# Verify and get the actual resource ID
EMAIL_RESOURCE_ID=$(get_resource_by_path "/accounts/{id}/email")
if [ -z "$EMAIL_RESOURCE_ID" ]; then
    echo -e "${RED}✗ Failed to get /accounts/{id}/email resource ID${NC}"
    exit 1
fi

# Create PUT /accounts/{id}/email method
create_method_integration "$EMAIL_RESOURCE_ID" "PUT" "$UPDATE_EMAIL_ARN" "updateEmail"
enable_cors "$EMAIL_RESOURCE_ID" "PUT"

# Deploy API
echo -e "${YELLOW}Deploying API to stage: ${STAGE_NAME}...${NC}"
aws apigateway create-deployment \
    --rest-api-id "$API_ID" \
    --stage-name "$STAGE_NAME" \
    --region "$REGION" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    API_URL="https://${API_ID}.execute-api.${REGION}.amazonaws.com/${STAGE_NAME}"
    echo -e "${GREEN}✓ API deployed successfully${NC}"
    echo -e "${GREEN}API URL: ${API_URL}${NC}"
else
    echo -e "${YELLOW}Deployment may have failed or already exists${NC}"
    # Try to get existing deployment
    API_URL="https://${API_ID}.execute-api.${REGION}.amazonaws.com/${STAGE_NAME}"
    echo -e "${GREEN}API URL: ${API_URL}${NC}"
fi

echo -e "${GREEN}✓ API Gateway setup completed successfully${NC}"
echo -e "${YELLOW}API ID: ${API_ID}${NC}"
echo -e "${YELLOW}API URL: ${API_URL}${NC}"

