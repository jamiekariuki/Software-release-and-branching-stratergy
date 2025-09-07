/* terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }testing
} */

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}
