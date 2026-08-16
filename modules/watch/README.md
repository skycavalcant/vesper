# Vesper Watch

Event collection module for Vesper autonomous resilience platform.

## Overview

Vesper Watch monitors AWS events and collects failure signals from:
- EC2 instance state changes (stopped, terminated)
- EC2 status check failures
- AWS Health events

Events are stored in DynamoDB for processing by Vesper Brain (future module).

## Architecture

```
EventBridge (EC2 events) → Lambda (collector.py) → DynamoDB (vesper-events)
```

## Components

- **collector.py** - Lambda function that processes events
- **DynamoDB table** - Stores events with TTL and GSI for queries
- **EventBridge rules** - Captures EC2 state changes and health events

## Local Development

### Prerequisites

- Python 3.12
- pip
- pytest (for tests)

### Install dependencies

```bash
cd modules/watch/src
pip install -r requirements.txt
```

### Run tests

```bash
cd modules/watch
pytest tests/ -v
```

## Deployment

See main project README for deployment instructions.

## Event Schema

Events stored in DynamoDB:

```json
{
  "event_id": "aws.ec2-2026-08-09T10:00:00Z-i-1234567890abcdef0",
  "timestamp": "2026-08-09T10:00:00Z",
  "source": "aws.ec2",
  "event_type": "EC2 Instance State-change Notification",
  "detail": "{\"instance-id\": \"i-1234567890abcdef0\", \"state\": \"stopped\"}",
  "processed": false,
  "created_at": "2026-08-09T10:00:05Z"
}
```

## Security

- Lambda runs with least privilege IAM role
- Only write access to DynamoDB events table
- CloudWatch Logs retention: 7 days (dev)
- No VPC required (serverless)
