# Terraform and Provider Version Requirements

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}