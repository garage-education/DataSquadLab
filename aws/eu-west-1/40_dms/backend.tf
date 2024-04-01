terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key = "40_dms/terraform.tfstate"
    region = "eu-west-1"
  }
}