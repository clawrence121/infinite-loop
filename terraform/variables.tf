# Root Variables Configuration

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "coding-agent"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for coding agents"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for coding agent instances (will be created in Day 2)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the SSH key pair (optional, SSM is preferred)"
  type        = string
  default     = ""
}

variable "enable_auto_shutdown" {
  description = "Enable automatic shutdown of idle instances"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Hours of inactivity before auto-shutdown"
  type        = number
  default     = 2
}

variable "allowed_users" {
  description = "List of IAM users allowed to manage coding agents"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}