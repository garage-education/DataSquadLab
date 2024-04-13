terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "21_eks_infra_apps/terraform.tfstate"
    region = "eu-west-1"
  }
}