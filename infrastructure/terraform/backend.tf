/* terraform {
  backend "s3" {
    bucket = "850502433430-app-dev"
    region = "us-east-1"
    key    = "app.tfstate"
  }
} */

terraform {
  backend "s3" {
    bucket         = "850502433430-app-dev"
    key            = "networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
