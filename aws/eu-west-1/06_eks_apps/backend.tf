terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "06_eks_apps/terraform.tfstate"
    region = "eu-west-1"
  }
}