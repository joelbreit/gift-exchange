const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require('@aws-sdk/lib-dynamodb');
const crypto = require('crypto');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.ACCOUNTS_TABLE_NAME;

exports.handler = async (event) => {
    try {
        const id = event.pathParameters?.id;
        const body = JSON.parse(event.body || '{}');
        const { currentPassword, newPassword } = body;

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

        if (!currentPassword || !newPassword) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Missing required fields: currentPassword, newPassword',
                    code: 'VALIDATION_ERROR'
                })
            };
        }

        if (newPassword.length < 8) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'New password must be at least 8 characters',
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

        // Verify current password
        const currentPasswordHash = crypto.createHash('sha256').update(currentPassword).digest('hex');
        if (getResult.Item.password !== currentPasswordHash) {
            return {
                statusCode: 401,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    message: 'Current password is incorrect',
                    code: 'UNAUTHORIZED'
                })
            };
        }

        // Hash new password
        const newPasswordHash = crypto.createHash('sha256').update(newPassword).digest('hex');

        // Update password
        await docClient.send(new UpdateCommand({
            TableName: TABLE_NAME,
            Key: { id },
            UpdateExpression: 'SET password = :password',
            ExpressionAttributeValues: {
                ':password': newPasswordHash
            }
        }));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: 'Password updated successfully'
            })
        };
    } catch (error) {
        console.error('Error updating password:', error);
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

