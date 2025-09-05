terraform {
  backend "s3" {
    bucket = "850502433430-app-dev"
    region = "us-east-1"
    key    = "app.tfstate"
  }
}