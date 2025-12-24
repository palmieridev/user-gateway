# Cognito User Pool Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "enable_mfa" {
  description = "Enable MFA for the user pool"
  type        = bool
  default     = true
}

variable "enable_advanced_security" {
  description = "Enable advanced security features"
  type        = bool
  default     = true
}

variable "password_minimum_length" {
  description = "Minimum length for passwords"
  type        = number
  default     = 12
}

variable "password_require_uppercase" {
  description = "Require uppercase characters in password"
  type        = bool
  default     = true
}

variable "password_require_lowercase" {
  description = "Require lowercase characters in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Require symbols in password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Validity period for temporary passwords in days"
  type        = number
  default     = 7
}

variable "user_pool_domain" {
  description = "Domain prefix for Cognito hosted UI"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
