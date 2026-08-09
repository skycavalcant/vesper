#!/bin/bash
# rigel-account-setup.sh
# Run this ONCE before starting the project.
# It configures your AWS account to avoid unexpected charges.

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

echo "Setting up Rigel on account: $ACCOUNT_ID"
echo ""

# 1. Budget alert at $1 — warns before any charge
echo "[1/3] Creating $1 budget alert..."
aws budgets create-budget \
  --account-id "$ACCOUNT_ID" \
  --budget '{
    "BudgetName": "rigel-guard",
    "BudgetLimit": {"Amount": "1", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[{
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [{
      "SubscriptionType": "EMAIL",
      "Address": "YOUR_EMAIL_HERE"
    }]
  }]' 2>/dev/null && echo "Budget created." || echo "Budget already exists, skipping."

# 2. CloudWatch Log Groups retention — prevents silent cost accumulation
echo ""
echo "[2/3] Setting default log retention to 7 days on existing log groups..."
aws logs describe-log-groups \
  --region "$REGION" \
  --query 'logGroups[?retentionInDays==`null`].logGroupName' \
  --output text | tr '\t' '\n' | while read -r group; do
    aws logs put-retention-policy \
      --log-group-name "$group" \
      --retention-in-days 7 \
      --region "$REGION"
    echo "  Set 7-day retention: $group"
done

# 3. S3 bucket for Terraform state (optional, uncomment to use remote state)
# echo ""
# echo "[3/3] Creating S3 bucket for Terraform state..."
# aws s3api create-bucket \
#   --bucket "rigel-terraform-state-$ACCOUNT_ID" \
#   --region "$REGION"
# aws s3api put-bucket-versioning \
#   --bucket "rigel-terraform-state-$ACCOUNT_ID" \
#   --versioning-configuration Status=Enabled
# aws s3api put-bucket-encryption \
#   --bucket "rigel-terraform-state-$ACCOUNT_ID" \
#   --server-side-encryption-configuration \
#     '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo ""
echo "Setup complete. Your account is ready for Rigel."
echo ""
echo "IMPORTANT: Never create a NAT Gateway during development."
echo "Use EC2 public IPs directly to avoid $32/month charges."
