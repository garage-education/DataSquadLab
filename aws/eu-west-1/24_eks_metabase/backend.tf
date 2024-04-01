terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "24_eks_metabase/terraform.tfstate"
    region = "eu-west-1"
  }
}