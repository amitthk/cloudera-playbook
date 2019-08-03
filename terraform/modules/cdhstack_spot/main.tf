resource "aws_security_group" "cdhstack" {
  name = "${format("%s-app-sg", var.cdh_stack_name)}"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.ingress_from_port}"
    to_port     = "${var.ingress_to_port}"
    protocol    = "tcp"
    cidr_blocks = ["${list(var.public_subnets_cidr_blocks)}", "${list(var.private_subnets_cidr_blocks)}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets_cidr_blocks}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
  
  tags {
    Group = "${var.cdh_stack_name}"
  }
}


resource "aws_subnet" "cdh_private_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.private_subnets_cidr_blocks}"
  availability_zone = "${var.availability_zone}"

  tags = {
    Name = "cdh_private_subnet"
  }
}

/*
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "cdhstack-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}
*/