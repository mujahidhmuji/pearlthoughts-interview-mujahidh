terraform {
  required_version = ">= 0.12"
  # Uncomment only if you would like not to use s3 as backend
  backend "s3" {
    bucket   = "mujahidh-my-tf-state-bucket-emeka"
    encrypt  =  true
    key      = "terraform.tfstate"
    region   = "us-west-2"
    profile  = "cloud_user@838734154092"
  }
}

provider "aws" {
  region = var.aws_region
  access_key = "AKIA4GSDTRFWIMCRDUB3" 
  secret_key = "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"
}

resource "aws_codecommit_repository" "code_repo" {
  repository_name = "nodejs-app"
  description     = "This is a Sample nodejs App Repository"
}

resource "null_resource" "image" {

  provisioner "local-exec" {
    command     = <<EOF
       git init
       git add .
       git commit -m "Initial Commit"
       git remote add origin ${aws_codecommit_repository.code_repo.clone_url_http}
       git push -u origin master
   EOF
    working_dir = "nodejs-app" #"nodejs_app"
  }
  depends_on = [
    aws_codecommit_repository.code_repo,
  ]

}

resource "null_resource" "clean_up" {

  provisioner "local-exec" {
    when        = destroy
    command     = <<EOF
       rm -rf .git/
   EOF
    working_dir = "nodejs-app" #"nodejs_app"

  }
}

resource "aws_s3_bucket" "cicd_bucket" {
  bucket        = var.artifacts_bucket_name
  acl           = "private"
  force_destroy = true
}