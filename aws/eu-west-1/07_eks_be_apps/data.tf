data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "datasquad-terraform-state-backend"
    key = "04_eks/terraform.tfstate"
    region = "eu-west-1"
  }
}