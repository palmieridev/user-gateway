# Global variables for the Secure IAM project

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "user-gateway"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "enable_mfa" {
  description = "Enable MFA for Cognito User Pool"
  type        = bool
  default     = true
}

variable "enable_advanced_security" {
  description = "Enable advanced security features in Cognito"
  type        = bool
  default     = true
}

variable "api_throttle_rate" {
  description = "API Gateway throttle rate limit"
  type        = number
  default     = 1000
}

variable "api_throttle_burst" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 2000
}
