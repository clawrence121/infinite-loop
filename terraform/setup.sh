#!/bin/bash

# Setup script for Remote Coding Agents Terraform Infrastructure
# This script helps initialize and validate the Terraform configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running from the correct directory
if [ ! -f "main.tf" ]; then
    print_error "This script must be run from the terraform directory"
    exit 1
fi

print_status "Starting Remote Coding Agents Terraform Setup"
echo "=============================================="

# Check for required tools
print_status "Checking prerequisites..."

# Check for Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    echo "Visit: https://www.terraform.io/downloads"
    exit 1
else
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2)
    print_status "Terraform version: $TERRAFORM_VERSION"
fi

# Check for AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install AWS CLI first."
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
else
    AWS_VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
    print_status "AWS CLI version: $AWS_VERSION"
fi

# Check for jq (optional but helpful)
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. Consider installing it for better JSON parsing."
    echo "Visit: https://stedolan.github.io/jq/download/"
fi

# Check AWS credentials
print_status "Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region || echo "us-east-1")
    print_status "AWS Account ID: $ACCOUNT_ID"
    print_status "AWS Region: $REGION"
else
    print_error "AWS credentials are not configured properly."
    echo "Please run 'aws configure' to set up your credentials."
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Format Terraform files
print_status "Formatting Terraform files..."
terraform fmt -recursive

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
if terraform validate; then
    print_status "Terraform configuration is valid!"
else
    print_error "Terraform configuration validation failed!"
    exit 1
fi

# Create tfvars file if it doesn't exist
TFVARS_FILE="environments/dev/terraform.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    print_warning "terraform.tfvars file not found. Creating from template..."
    
    # Check if we should restore from .gitignore
    if [ -f "environments/dev/terraform.tfvars.example" ]; then
        cp environments/dev/terraform.tfvars.example $TFVARS_FILE
        print_status "Created $TFVARS_FILE from example file"
    else
        print_warning "No example tfvars file found. Please configure $TFVARS_FILE manually."
    fi
fi

# Plan the deployment
print_status "Creating Terraform plan..."
echo ""
echo "Running: terraform plan -var-file=$TFVARS_FILE -out=tfplan"
echo ""

if terraform plan -var-file=$TFVARS_FILE -out=tfplan; then
    print_status "Terraform plan created successfully!"
    echo ""
    echo "=============================================="
    print_status "Setup complete! Next steps:"
    echo ""
    echo "1. Review the plan above carefully"
    echo "2. If everything looks good, apply the configuration:"
    echo "   terraform apply tfplan"
    echo ""
    echo "3. To apply with auto-approve (use with caution):"
    echo "   terraform apply -var-file=$TFVARS_FILE -auto-approve"
    echo ""
    echo "4. After deployment, save the outputs:"
    echo "   terraform output -json > outputs.json"
    echo ""
    echo "5. To destroy all resources later:"
    echo "   terraform destroy -var-file=$TFVARS_FILE"
    echo ""
else
    print_error "Terraform plan failed!"
    exit 1
fi

# Optional: Show estimated costs
if command -v infracost &> /dev/null; then
    print_status "Calculating estimated costs with Infracost..."
    infracost breakdown --path . --terraform-var-file $TFVARS_FILE
fi

print_status "Setup script completed!"