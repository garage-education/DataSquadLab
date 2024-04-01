terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key = "15_rds/terraform.tfstate"
    region = "eu-west-1"
  }
}