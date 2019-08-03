resource "aws_instancence" "tomcatserver" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"

  tags {
      Name = "tomcatserver"
      Description = "Used to deploy wars to tomcat"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instancence.tomcatserver.public_ip} >> file.txt"
  }

}