# Agents

Keep all architecture as simple as possible.

Functions will use node.js Lambda functions defined in the functions folder, and their code will be copied from their using the scripts, not duplicated in the scripts.

Scripts should be idempotent bash scripts that use color output and use the AWS CLI. Each setup script will have a matching teardown script to undo it e.g. 3_setup_authentication.sh and 3_teardown_authentication.sh. The setup and teardown scripts will be numbered so that they can be run in order of 1 to n to duplicate setup and n to 1 to teardown everything.

AWS services used will include Lambda, DynamoDB, S3, API Gateway, and Cognito.

Keep track of the AWS resources created in a file called AWS_Resources.md in the docs folder.

AWS resources should be created in the us-east-1 region.

Keep track of the API architecture in an OpenAPI specification file called openapi.yaml in the docs folder.