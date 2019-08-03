resource "aws_spot_instance_request" "spot_cdh_scm" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"
    wait_for_fulfillment = true
    associate_public_ip_address = true
    availability_zone = "${var.availability_zone}"
    spot_price = "${var.spot_price}"
    security_groups = ["${aws_security_group.cdhstack.name}"]

  tags {
      Name = "spot_cdh_scm"
      Description = "spot_cdh_scm"
  }
  
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
  }

  volume_tags {
      Name = "spot_cdh_scm"
  }
  root_block_device {
    delete_on_termination = true
 }

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=spot_cdh_scm"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }
}



resource "null_resource" "after-spot_cdh_scm" {
  depends_on = ["aws_spot_instance_request.spot_cdh_scm"]
  provisioner "local-exec" {
    command = "echo ' spot_cdh_scm ${join("\n",aws_spot_instance_request.spot_cdh_scm.*.id)} ${join("\n",aws_spot_instance_request.spot_cdh_scm.*.public_ip)}' >> inventory.txt"
  }
}