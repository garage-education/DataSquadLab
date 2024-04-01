terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend"
    key    = "25_eks_airflow/terraform.tfstate"
    region = "eu-west-1"
  }
}