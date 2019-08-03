provider "aws" {
    region = "${var.region}"
    access_key ="${var.aws_access_key}"
    secret_key ="${var.aws_secret_key}"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair_name" {}
variable "region" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "cdh_stack_name" {}
variable "ami_id" {}
variable "public_subnets_cidr_blocks" {
  default = []
}
variable "private_subnets_cidr_blocks" {
  default = []
}
variable "cdh_master_count" {}
variable "cdh_worker_count" {}
variable "ingress_from_port" {}
variable "ingress_to_port" {}