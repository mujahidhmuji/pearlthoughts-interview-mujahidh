terraform {
  required_version = ">= 0.12"
}


provider "aws" {
  region = var.aws_region
  access_key = "AKIA4GSDTRFWIMCRDUB3" 
  secret_key = "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"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "mujahidh-my-tf-state-bucket-emeka"
  acl           = "private"
  force_destroy = true

  tags = {
    Name        = "My bucket"
    Environment = var.env_name
  }
}