terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key = "04_rds/terraform.tfstate"
    region = "eu-west-1"
  }
}