terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key = "02_kms/terraform.tfstate"
    region = "eu-west-1"
  }
}