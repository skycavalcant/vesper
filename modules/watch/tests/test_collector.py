"""
Unit tests for Vesper Watch Event Collector
"""
import json
import os
from unittest.mock import patch, MagicMock
import pytest

# Set environment variables before importing the module
os.environ['EVENTS_TABLE_NAME'] = 'test-vesper-events'

from modules.watch.src.collector import lambda_handler


@pytest.fixture
def sample_ec2_event():
    """Sample EC2 state change event from EventBridge."""
    return {
        "version": "0",
        "id": "12345678-1234-1234-1234-123456789012",
        "detail-type": "EC2 Instance State-change Notification",
        "source": "aws.ec2",
        "account": "123456789012",
        "time": "2026-08-09T10:00:00Z",
        "region": "us-east-1",
        "resources": [
            "arn:aws:ec2:us-east-1:123456789012:instance/i-1234567890abcdef0"
        ],
        "detail": {
            "instance-id": "i-1234567890abcdef0",
            "state": "stopped"
        }
    }


@pytest.fixture
def mock_dynamodb_table():
    """Mock DynamoDB table."""
    with patch('modules.watch.src.collector.table') as mock_table:
        mock_table.put_item = MagicMock(return_value={'ResponseMetadata': {'HTTPStatusCode': 200}})
        yield mock_table


def test_lambda_handler_success(sample_ec2_event, mock_dynamodb_table):
    """Test successful event processing."""
    context = MagicMock()

    response = lambda_handler(sample_ec2_event, context)

    assert response['statusCode'] == 200
    assert 'event_id' in json.loads(response['body'])
    mock_dynamodb_table.put_item.assert_called_once()


def test_lambda_handler_stores_correct_data(sample_ec2_event, mock_dynamodb_table):
    """Test that correct data is stored in DynamoDB."""
    context = MagicMock()

    lambda_handler(sample_ec2_event, context)

    # Get the item that was stored
    call_args = mock_dynamodb_table.put_item.call_args
    stored_item = call_args.kwargs['Item']

    assert stored_item['source'] == 'aws.ec2'
    assert stored_item['event_type'] == 'EC2 Instance State-change Notification'
    assert stored_item['processed'] is False
    assert 'event_id' in stored_item
    assert 'timestamp' in stored_item


def test_lambda_handler_missing_detail(mock_dynamodb_table):
    """Test handling of event with missing detail field."""
    event = {
        "source": "aws.ec2",
        "detail-type": "EC2 Instance State-change Notification",
        "time": "2026-08-09T10:00:00Z"
    }
    context = MagicMock()

    response = lambda_handler(event, context)

    # Should still process, but with empty detail
    assert response['statusCode'] == 200
    mock_dynamodb_table.put_item.assert_called_once()


def test_lambda_handler_dynamodb_error(sample_ec2_event):
    """Test handling of DynamoDB errors."""
    from botocore.exceptions import ClientError

    with patch('modules.watch.src.collector.table') as mock_table:
        mock_table.put_item.side_effect = ClientError(
            {'Error': {'Code': 'ValidationException', 'Message': 'Invalid item'}},
            'PutItem'
        )

        context = MagicMock()
        response = lambda_handler(sample_ec2_event, context)

        assert response['statusCode'] == 500
        assert 'error' in json.loads(response['body'])


def test_event_id_uniqueness(sample_ec2_event, mock_dynamodb_table):
    """Test that event IDs are unique based on source, time, and instance."""
    context = MagicMock()

    # Process same event twice
    response1 = lambda_handler(sample_ec2_event, context)
    response2 = lambda_handler(sample_ec2_event, context)

    body1 = json.loads(response1['body'])
    body2 = json.loads(response2['body'])

    # Event IDs should be identical for same event (idempotency)
    assert body1['event_id'] == body2['event_id']
