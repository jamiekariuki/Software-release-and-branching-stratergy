resource "aws_s3_bucket" "state" {
   bucket        = "${var.aws_account_id}-app-${var.ENV_PREFIX}"
   force_destroy = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
