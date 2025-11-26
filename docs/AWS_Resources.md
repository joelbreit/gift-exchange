# AWS Resources

## Overview
This document tracks AWS resources created for the Gift Exchange application and the plan for implementing the API.

## First Stage Implementation Plan

### Resources Needed

1. **DynamoDB Table**: `gift-exchange-accounts`
   - Primary Key: `id` (String)
   - Attributes: `email`, `name`, `password` (hashed)
   - Region: `us-east-1`

2. **Lambda Functions** (in `functions/` folder):
   - `createAccount` - POST /accounts
   - `updatePassword` - PUT /accounts/{id}/password
   - `updateEmail` - PUT /accounts/{id}/email
   - `deleteAccount` - DELETE /accounts/{id}

3. **API Gateway REST API**: `gift-exchange-api`
   - Endpoints mapped to Lambda functions
   - CORS enabled

4. **IAM Role**: `gift-exchange-lambda-role`
   - Permissions for DynamoDB access

### Setup Scripts (in order)

1. **1_setup_dynamodb.sh**
   - Create DynamoDB table `gift-exchange-accounts`
   - Set region to `us-east-1`
   - Configure table schema

2. **2_setup_iam.sh**
   - Create IAM role `gift-exchange-lambda-role`
   - Attach policy for DynamoDB read/write access
   - Attach basic Lambda execution policy

3. **3_setup_lambda.sh**
   - Package and deploy Lambda functions from `functions/` folder
   - Functions: `createAccount`, `updatePassword`, `updateEmail`, `deleteAccount`
   - Attach IAM role to each function
   - Set environment variables (table name, region)

4. **4_setup_api_gateway.sh**
   - Create REST API `gift-exchange-api`
   - Create resources and methods for each endpoint
   - Integrate methods with corresponding Lambda functions
   - Enable CORS
   - Deploy API to a stage (e.g., `dev`)

### Teardown Scripts (reverse order)

1. **4_teardown_api_gateway.sh**
2. **3_teardown_lambda.sh**
3. **2_teardown_iam.sh**
4. **1_teardown_dynamodb.sh**

### Lambda Function Structure

Each Lambda function in `functions/` should:
- Export a handler function
- Use AWS SDK v3 for DynamoDB operations
- Return proper HTTP responses for API Gateway
- Handle errors gracefully

Example structure:
```
functions/
  createAccount/
    index.js
    package.json
  updatePassword/
    index.js
    package.json
  updateEmail/
    index.js
    package.json
  deleteAccount/
    index.js
    package.json
```

### Environment Variables

Lambda functions will use:
- `ACCOUNTS_TABLE_NAME`: `gift-exchange-accounts`
- `AWS_REGION`: `us-east-1`

## Created Resources

### DynamoDB
- **Table**: `gift-exchange-accounts`
  - Region: `us-east-1`
  - Primary Key: `id` (String)
  - Billing Mode: PAY_PER_REQUEST
  - ARN: `arn:aws:dynamodb:us-east-1:609406001911:table/gift-exchange-accounts`
  - Created: 2025-11-25

### IAM
- **Role**: `gift-exchange-lambda-role`
  - ARN: `arn:aws:iam::609406001911:role/gift-exchange-lambda-role`
  - Policies:
    - `AWSLambdaBasicExecutionRole` (AWS managed policy)
    - `DynamoDBAccess` (inline policy for gift-exchange-accounts table)
  - Created: 2025-11-25

