terraform {
  backend "s3" {
    bucket = "datasquad-terraform-state-backend-eu-west-1"
    key    = "03_eks/terraform.tfstate"
    region = "eu-west-1"
    #dynamodb_table = "foundations_terraform_state"
  }
}

