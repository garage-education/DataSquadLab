variable "prefix" {}
variable "name" {}
variable "owner" {}
variable "environment" {}
variable "region" {}
variable "vpc_cidr" {}
variable "ManagedBy" {}
variable "ami_type" {
  default = "AL2_x86_64"
}
variable "instance_types" {
  default = "t3.large"
}