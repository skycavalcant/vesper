"""
Vesper Watch - Event Collector
Collects EC2 failure events from EventBridge and stores them in DynamoDB
"""
import json
import os
from datetime import datetime
from typing import Dict, Any

import boto3
from botocore.exceptions import ClientError


dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('EVENTS_TABLE_NAME', 'vesper-events')
table = dynamodb.Table(table_name)


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Process EC2 failure events from EventBridge.

    Expected event structure from EventBridge:
    {
        "source": "aws.ec2",
        "detail-type": "EC2 Instance State-change Notification",
        "detail": {
            "instance-id": "i-1234567890abcdef0",
            "state": "stopped"
        }
    }
    """
    try:
        print(f"Received event: {json.dumps(event)}")

        # Extract event metadata
        event_source = event.get('source', 'unknown')
        event_type = event.get('detail-type', 'unknown')
        event_detail = event.get('detail', {})
        event_time = event.get('time', datetime.utcnow().isoformat())

        # Generate unique event ID
        event_id = f"{event_source}-{event_time}-{event_detail.get('instance-id', 'unknown')}"

        # Prepare item for DynamoDB
        item = {
            'event_id': event_id,
            'timestamp': event_time,
            'source': event_source,
            'event_type': event_type,
            'detail': json.dumps(event_detail),
            'processed': False,
            'created_at': datetime.utcnow().isoformat()
        }

        # Store in DynamoDB
        response = table.put_item(Item=item)

        print(f"Event stored successfully: {event_id}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Event processed successfully',
                'event_id': event_id
            })
        }

    except ClientError as e:
        error_msg = f"DynamoDB error: {e.response['Error']['Message']}"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_msg})
        }

    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_msg})
        }


def get_event_by_id(event_id: str) -> Dict[str, Any]:
    """Retrieve an event from DynamoDB by ID (helper for testing)."""
    try:
        response = table.get_item(Key={'event_id': event_id})
        return response.get('Item', {})
    except ClientError as e:
        print(f"Error retrieving event: {e.response['Error']['Message']}")
        return {}
