const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.ACCOUNTS_TABLE_NAME;

exports.handler = async (event) => {
    try {
        const id = event.pathParameters?.id;

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

        // Check if account exists
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

        // Delete account
        await docClient.send(new DeleteCommand({
            TableName: TABLE_NAME,
            Key: { id }
        }));

        return {
            statusCode: 204,
            headers: {
                'Access-Control-Allow-Origin': '*'
            },
            body: ''
        };
    } catch (error) {
        console.error('Error deleting account:', error);
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

