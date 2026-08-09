#!/bin/bash
# Build Lambda deployment package for Rigel Watch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
WATCH_SRC="$PROJECT_ROOT/modules/watch/src"

echo "Building Rigel Watch Lambda function..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/package"

# Copy source code
echo "Copying source code..."
cp "$WATCH_SRC/collector.py" "$BUILD_DIR/package/"

# Install dependencies
if [ -f "$WATCH_SRC/requirements.txt" ]; then
    echo "Installing dependencies..."
    pip install -q -r "$WATCH_SRC/requirements.txt" -t "$BUILD_DIR/package/" --upgrade
fi

# Create ZIP file
echo "Creating deployment package..."
cd "$BUILD_DIR/package"
zip -q -r ../watch-lambda.zip .
cd "$PROJECT_ROOT"

# Show package info
PACKAGE_SIZE=$(du -h "$BUILD_DIR/watch-lambda.zip" | cut -f1)
echo ""
echo "✅ Lambda package created: build/watch-lambda.zip ($PACKAGE_SIZE)"
echo ""
echo "Next steps:"
echo "  1. cd infra/environments/dev"
echo "  2. terraform init"
echo "  3. terraform plan"
echo "  4. terraform apply"
