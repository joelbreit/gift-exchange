const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, UpdateCommand, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.ACCOUNTS_TABLE_NAME;

exports.handler = async (event) => {
    try {
        const id = event.pathParameters?.id;
        const body = JSON.parse(event.body || '{}');
        const { email } = body;

        // Validation
        if (!id) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Missing account ID',
                    code: 'VALIDATION_ERROR'
                })
            };
        }

        if (!email) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Missing required field: email',
                    code: 'VALIDATION_ERROR'
                })
            };
        }

        // Get account
        const getResult = await docClient.send(new GetCommand({
            TableName: TABLE_NAME,
            Key: { id }
        }));

        if (!getResult.Item) {
            return {
                statusCode: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Account not found',
                    code: 'NOT_FOUND'
                })
            };
        }

        // Check if new email already exists (and is different from current)
        if (email !== getResult.Item.email) {
            const scanResult = await docClient.send(new ScanCommand({
                TableName: TABLE_NAME,
                FilterExpression: 'email = :email',
                ExpressionAttributeValues: {
                    ':email': email
                }
            }));

            if (scanResult.Items && scanResult.Items.length > 0) {
                return {
                    statusCode: 409,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    body: JSON.stringify({
                        message: 'Email already exists',
                        code: 'CONFLICT'
                    })
                };
            }
        }

        // Update email
        await docClient.send(new UpdateCommand({
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'SET email = :email',
            ExpressionAttributeValues: {
                ':email': email
            },
            ReturnValues: 'ALL_NEW'
        }));

        // Get updated account
        const updatedResult = await docClient.send(new GetCommand({
            TableName: TABLE_NAME,
            Key: { id }
        }));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                id: updatedResult.Item.id,
                email: updatedResult.Item.email,
                name: updatedResult.Item.name
            })
        };
    } catch (error) {
        console.error('Error updating email:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: 'Internal server error',
                code: 'INTERNAL_ERROR'
            })
        };
    }
};

