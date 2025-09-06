/* terraform {
  backend "s3" {
    bucket = "850502433430-app-dev"
    region = "us-east-1"
    key    = "app.tfstate"
  }
} */

terraform {
  backend "s3" {
    bucket         = "my-terraform-states"
    key            = "networking/${terraform.workspace}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
