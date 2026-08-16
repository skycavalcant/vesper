/**
 * Input variables for Vesper Watch module
 */

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vesper"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_zip_path" {
  description = "Path to Lambda function ZIP file"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention value."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = false
}
