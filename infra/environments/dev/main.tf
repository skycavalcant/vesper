/**
 * Rigel Watch - Development Environment
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Rigel"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

module "watch" {
  source = "../../modules/watch"

  project_name                 = var.project_name
  environment                  = "dev"
  aws_region                   = var.aws_region
  lambda_zip_path              = var.lambda_zip_path
  log_retention_days           = 7
  enable_point_in_time_recovery = false
}
