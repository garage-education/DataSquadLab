terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "17_eks_db_admin/terraform.tfstate"
    region = "eu-west-1"
  }
}