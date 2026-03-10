"""
AWS Lambda function for CycleGlow Product Scanner
Routes: POST /analyze → Amazon Bedrock Nova Lite (multimodal)

Deploy via:
  1. Create Lambda function (Python 3.12, arm64)
  2. Add Bedrock invoke permission: bedrock:InvokeModel
  3. Create API Gateway (HTTP API) with POST /analyze route
  4. Set Lambda as integration target
  5. Enable CORS for iOS app

Environment: us-east-1 (Nova Lite availability)
"""

import json
import boto3
import base64

bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')
MODEL_ID = 'amazon.nova-lite-v1:0'


def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        base64_image = body.get('image', '')
        prompt = body.get('prompt', 'List all visible ingredients on this skincare product.')
        model_id = body.get('modelId', MODEL_ID)

        if not base64_image:
            return response(400, {'error': 'No image provided'})

        # Call Nova Lite with multimodal input
        payload = {
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "image": {
                                "format": "jpeg",
                                "source": {
                                    "bytes": base64_image
                                }
                            }
                        },
                        {
                            "text": prompt
                        }
                    ]
                }
            ],
            "inferenceConfig": {
                "maxNewTokens": 1000,
                "temperature": 0.2
            }
        }

        result = bedrock.invoke_model(
            modelId=model_id,
            contentType='application/json',
            accept='application/json',
            body=json.dumps(payload)
        )

        result_body = json.loads(result['body'].read())
        
        # Extract text from Nova response
        output_text = ''
        if 'output' in result_body and 'message' in result_body['output']:
            for content in result_body['output']['message'].get('content', []):
                if 'text' in content:
                    output_text += content['text']

        return response(200, {'analysis': output_text})

    except Exception as e:
        print(f'Error: {e}')
        return response(500, {'error': str(e)})


def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST,OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
        },
        'body': json.dumps(body)
    }
