resource "aws_security_group" "cdhstack" {
  name = "${format("%s-app-sg", var.cdh_stack_name)}"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.ingress_from_port}"
    to_port     = "${var.ingress_to_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets_cidr_blocks}", "${var.private_subnets_cidr_blocks}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets_cidr_blocks}"]
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