variable "aws_account_id" {
  type = string
}

variable "region" {
  type = string
}


variable "ENV_PREFIX" {
  type        = string
  description = "Environment prefix (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.ENV_PREFIX)
    error_message = "ENV_PREFIX must be one of: dev, staging, prod."
  }
}
