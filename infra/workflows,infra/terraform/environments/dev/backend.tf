terraform {
  backend "s3" {
    bucket         = "my-terraform-state-$(aws sts get-caller-identity --query Account --output text)"
    key            = "dev/lamp.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}