import json
import os
from typing import Dict, Any

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda handler for profile API endpoints.
    Handles GET and PUT requests for user profiles.
    
    Args:
        event: API Gateway Lambda Proxy Input Format
        context: Lambda Context runtime methods and attributes
        
    Returns:
        API Gateway Lambda Proxy Output Format
    """
    
    # Extract HTTP method
    http_method = event.get('httpMethod', '')
    
    # Extract user information from Cognito authorizer claims
    claims = event.get('requestContext', {}).get('authorizer', {}).get('claims', {})
    user_email = claims.get('email', 'unknown')
    user_sub = claims.get('sub', 'unknown')
    user_name = claims.get('name', 'Unknown User')
    
    # CORS headers
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'GET,PUT,OPTIONS'
    }
    
    try:
        if http_method == 'GET':
            # Handle GET /profile - Return user profile
            response_body = {
                'userId': user_sub,
                'email': user_email,
                'name': user_name,
                'message': 'Profile retrieved successfully',
                'claims': claims  # Include all claims for debugging (remove in production)
            }
            
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps(response_body)
            }
            
        elif http_method == 'PUT':
            # Handle PUT /profile - Update user profile
            try:
                body = json.loads(event.get('body', '{}'))
            except json.JSONDecodeError:
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({'error': 'Invalid JSON in request body'})
                }
            
            # In a real application, you would update the profile in a database
            # For this example, we'll just echo back the updated information
            response_body = {
                'userId': user_sub,
                'email': user_email,
                'updatedFields': body,
                'message': 'Profile updated successfully'
            }
            
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps(response_body)
            }
            
        else:
            # Unsupported HTTP method
            return {
                'statusCode': 405,
                'headers': headers,
                'body': json.dumps({'error': f'Method {http_method} not allowed'})
            }
            
    except Exception as e:
        # Handle unexpected errors
        print(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
