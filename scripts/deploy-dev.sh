#!/bin/bash
# Deploy Vesper Watch to development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRA_DEV="$PROJECT_ROOT/infra/environments/dev"

echo "Deploying Vesper Watch to development environment..."
echo ""

# Build Lambda package
echo "[1/3] Building Lambda package..."
bash "$SCRIPT_DIR/build-lambda.sh"

# Initialize Terraform
echo ""
echo "[2/3] Initializing Terraform..."
cd "$INFRA_DEV"
terraform init

# Apply Terraform
echo ""
echo "[3/3] Deploying infrastructure..."
terraform apply

echo ""
echo "✅ Deployment complete!"
echo ""
echo "To view deployed resources:"
echo "  terraform output"
echo ""
echo "To test the function:"
echo "  bash scripts/test-event.sh"
