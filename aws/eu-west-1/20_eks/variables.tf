variable "prefix" {}
variable "name" {}
variable "owner" {}
variable "environment" {}
variable "region" {}
variable "ManagedBy" {}
variable "vpc_cidr" {}
variable "ami_type" {
  default = "AL2_x86_64"
}
variable "instance_types" {
  default = "t3.large"
}
variable "eks_min_size" {
  default = 2
}
variable "eks_max_size" {
  default = 4
}
variable "eks_desired_size" {
  default = 3
}
variable "eks_nodes_disk_size" {
  default = 50
}
