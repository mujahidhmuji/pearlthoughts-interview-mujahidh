
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# Example of a list variable
variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "env" {
  description = "Targeted Deployment environment"
  default     = "Development"
}

variable "nodejs_project_repository_branch" {
  description = "nodejs Project Repository branch to connect to"
  default     = "master"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "emeka18-cicd-artifacts-bucket"
}

variable "container_port" {
  description = "nodejs app container port"
  default     = 3000
}
variable "ACCOUNT_ID" {
  description = "account_id"
  default     = 838734154092
}
data "aws_caller_identity" "current" {}
locals {
    account_id = data.aws_caller_identity.current.account_id
}
output "account_id" {
  value = local.account_id
}

resource "aws_s3_bucket" "muji-test-bucket" {
  bucket = "muji-test-bucket-${local.account_id}"
}
variable "vpc_default_id" {
  default = "vpc-d3dcdcab"
}

variable "container_name" {
  default = "nodejs-app"
}

variable "ecs_image_ami" {
  type    = string
  default = "ami-072aaf1b030a33b6e"
  # run the following command to get the image ami for your region
  # aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended
}