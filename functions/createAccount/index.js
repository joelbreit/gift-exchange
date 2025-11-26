const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, ScanCommand } = require('@aws-sdk/lib-dynamodb');
const crypto = require('crypto');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.ACCOUNTS_TABLE_NAME;

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body || '{}');
        const { email, name, password } = body;

        // Validation
        if (!email || !name || !password) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Missing required fields: email, name, password',
                    code: 'VALIDATION_ERROR'
                })
            };
        }

        if (password.length < 8) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Password must be at least 8 characters',
                    code: 'VALIDATION_ERROR'
                })
            };
        }

        // Check if email already exists
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

        // Generate UUID for account ID
        const id = crypto.randomUUID();

        // Hash password (simple hash for now - in production use bcrypt)
        const passwordHash = crypto.createHash('sha256').update(password).digest('hex');

        // Create account
        await docClient.send(new PutCommand({
            TableName: TABLE_NAME,
            Item: {
                id,
                email,
                name,
                password: passwordHash
            }
        }));

        return {
            statusCode: 201,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                id,
                email,
                name
            })
        };
    } catch (error) {
        console.error('Error creating account:', error);
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

