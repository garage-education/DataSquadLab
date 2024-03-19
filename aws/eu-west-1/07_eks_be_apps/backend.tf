terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "07_eks_be_apps/terraform.tfstate"
    region = "eu-west-1"
  }
}