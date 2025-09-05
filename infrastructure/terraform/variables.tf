variable "aws_account_id" {
  type = string
}

variable "region" {
  type = string
}

//remote backend url
/* variable "bucket" {
  type = string
} */
//dev,stage,prod
variable "ENV_PREFIX" {
  type = string
}