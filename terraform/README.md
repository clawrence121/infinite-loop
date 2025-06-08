# Terraform Configuration for Remote Coding Agents Platform

This directory contains the infrastructure-as-code (IaC) configuration for deploying the Remote Coding Agents platform on AWS.

## Directory Structure

```
terraform/
├── main.tf              # Root configuration with provider and main resources
├── variables.tf         # Input variables for the root module
├── outputs.tf          # Output values from the deployment
├── README.md           # This file
├── 
├── modules/
│   ├── vpc/            # VPC and networking configuration
│   │   ├── main.tf     # VPC, subnets, security groups
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/        # EC2 instance module (Day 2+)
│   │   ├── main.tf
│   │   ├── user-data.sh
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── management/     # Lambda functions for instance management (Day 5)
│       ├── main.tf
│       ├── functions/
│       │   ├── create-instance.py
│       │   ├── stop-instance.py
│       │   └── terminate-instance.py
│       └── variables.tf
│
└── environments/
    └── dev/
        └── terraform.tfvars  # Development environment configuration
```

## Prerequisites

1. **AWS CLI** installed and configured with appropriate credentials
   ```bash
   aws configure
   ```

2. **Terraform** installed (version 1.0 or higher)
   ```bash
   terraform version
   ```

3. **AWS Account** with appropriate permissions to create:
   - VPC and networking resources
   - IAM roles and policies
   - EC2 instances
   - S3 buckets
   - Lambda functions (Day 5)

## Day 1: Basic Infrastructure Setup

The Day 1 configuration includes:

- **VPC** with public subnet and internet gateway
- **Security Group** for EC2 instances
- **IAM Role** with Session Manager permissions
- **S3 Bucket** for storing artifacts and configurations

### Deploying the Infrastructure

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Review the planned changes**
   ```bash
   terraform plan -var-file=environments/dev/terraform.tfvars
   ```

3. **Apply the configuration**
   ```bash
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

4. **Save the outputs**
   ```bash
   terraform output -json > outputs.json
   ```

### Important Outputs

After deployment, Terraform will output important values including:

- `vpc_id`: The ID of the created VPC
- `security_group_id`: Security group to attach to EC2 instances
- `iam_role_name`: IAM role for EC2 instances
- `instance_profile_name`: Instance profile to attach to EC2 instances
- `artifacts_bucket_name`: S3 bucket for storing artifacts

## Configuration Variables

Key variables that can be customized in `environments/dev/terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `project_name` | Name prefix for all resources | `coding-agent` |
| `environment` | Environment name (dev/staging/prod) | `dev` |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` |
| `instance_type` | EC2 instance type | `t3.medium` |
| `enable_auto_shutdown` | Enable auto-shutdown Lambda | `true` |
| `auto_shutdown_hours` | Hours before auto-shutdown | `2` |

## Security Considerations

1. **Session Manager Access**: EC2 instances are configured for AWS Session Manager access, eliminating the need for SSH keys and bastion hosts.

2. **Security Group**: The default security group allows:
   - Inbound: SSH (port 22) from anywhere (restricted by Session Manager)
   - Outbound: All traffic (required for package installations)

3. **IAM Permissions**: Minimal IAM permissions following the principle of least privilege.

4. **S3 Bucket**: Encrypted by default with versioning enabled and public access blocked.

## Cost Optimization

- **Auto-shutdown**: Lambda function (Day 5) automatically stops idle instances
- **Instance Type**: Default `t3.medium` provides good balance of performance and cost
- **Single AZ**: Development environment uses single availability zone to minimize costs

## Next Steps

After Day 1 infrastructure is deployed:

1. **Day 2**: Create custom AMI with pre-installed development tools
2. **Day 3**: Build CLI tool for managing instances
3. **Day 4**: Add VSCode remote development support
4. **Day 5**: Implement auto-shutdown Lambda and management functions

## Troubleshooting

### Terraform State Issues
If you encounter state issues:
```bash
terraform refresh -var-file=environments/dev/terraform.tfvars
```

### Permission Errors
Ensure your AWS credentials have the required permissions. You can test with:
```bash
aws sts get-caller-identity
```

### Resource Cleanup
To destroy all resources:
```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Contributing

When modifying the Terraform configuration:

1. Always run `terraform fmt` before committing
2. Update this README if adding new modules or variables
3. Test changes in a separate workspace first:
   ```bash
   terraform workspace new test
   terraform plan -var-file=environments/dev/terraform.tfvars
   ```
