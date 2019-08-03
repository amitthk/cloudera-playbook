provider "aws" {
    region = "${var.region}"
    access_key ="${var.aws_access_key}"
    secret_key ="${var.aws_secret_key}"
}

variable "spot_price" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair_name" {}
variable "region" {}
variable "availability_zone" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "cdh_stack_name" {}
variable "ami_id" {}
variable "vpc_cidr" {}
variable "public_subnets_cidr_blocks" {}
variable "private_subnets_cidr_blocks" {}
variable "spot_cdh_master_count" {}
variable "spot_cdh_worker_count" {}
variable "ingress_from_port" {}
variable "ingress_to_port" {}