#!/bin/bash
# Send a test EC2 event to Rigel Watch Lambda

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRA_DEV="$PROJECT_ROOT/infra/environments/dev"

# Get Lambda function name from Terraform output
cd "$INFRA_DEV"
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null)

if [ -z "$FUNCTION_NAME" ]; then
    echo "Error: Lambda function not deployed. Run './scripts/deploy-dev.sh' first."
    exit 1
fi

echo "Testing Rigel Watch with sample EC2 event..."
echo "Function: $FUNCTION_NAME"
echo ""

# Create test event
TEST_EVENT=$(cat <<EOF
{
  "version": "0",
  "id": "test-$(date +%s)",
  "detail-type": "EC2 Instance State-change Notification",
  "source": "aws.ec2",
  "account": "123456789012",
  "time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "region": "us-east-1",
  "resources": [
    "arn:aws:ec2:us-east-1:123456789012:instance/i-test123456"
  ],
  "detail": {
    "instance-id": "i-test123456",
    "state": "stopped"
  }
}
EOF
)

# Invoke Lambda
echo "Invoking Lambda function..."
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload "$TEST_EVENT" \
    --cli-binary-format raw-in-base64-out \
    /tmp/rigel-test-output.json

echo ""
echo "Response:"
cat /tmp/rigel-test-output.json | jq .
echo ""

# Get table name and query the event
TABLE_NAME=$(terraform output -raw dynamodb_table_name 2>/dev/null)
echo "Events in DynamoDB table ($TABLE_NAME):"
aws dynamodb scan \
    --table-name "$TABLE_NAME" \
    --max-items 5 \
    --output table \
    --query 'Items[*].[event_id.S, timestamp.S, source.S, event_type.S]'

echo ""
echo "✅ Test complete! Check CloudWatch Logs for details:"
LOG_GROUP=$(terraform output -raw cloudwatch_log_group 2>/dev/null)
echo "  aws logs tail $LOG_GROUP --follow"
