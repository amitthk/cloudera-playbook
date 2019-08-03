resource "aws_instance" "cdh_master" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"
    count = "${var.cdh_master_count}"
    security_groups = ["${aws_security_group.cdhstack.name}"]

  tags {
      Name = "cdh_master-${count.index}"
      Description = "cdh_master-${count.index}"
  }
  
  volume_tags {
      Name = "cdh_master-${count.index}"
  }
}

resource "null_resource" "after-cdh_master" {
  depends_on = ["aws_instance.cdh_master"]
  provisioner "local-exec" {
    command = "echo ' cdh_masters ${join(",",aws_instance.cdh_master.*.id)} ${join(",",aws_instance.cdh_master.*.public_ip)}' >> inventory.txt"
  }
}