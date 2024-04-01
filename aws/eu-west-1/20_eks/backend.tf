terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key = "20_eks/terraform.tfstate"
    region = "eu-west-1"
  }
}