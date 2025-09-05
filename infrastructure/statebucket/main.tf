resource "aws_s3_bucket" "state" {
   bucket        = "${var.aws_account_id}-app-${var.ENV_PREFIX}"
   force_destroy = true
}