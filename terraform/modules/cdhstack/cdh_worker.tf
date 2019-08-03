resource "aws_instance" "cdh_worker" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"
    count = "${var.cdh_worker_count}"
    security_groups = ["${aws_security_group.cdhstack.name}"]

  tags {
      Name = "cdh_worker-${count.index}"
      Description = "cdh_worker ${count.index}"
  }

  volume_tags {
      Name = "cdh_worker-${count.index}"
  }
}

resource "null_resource" "after-cdh_worker" {
  depends_on = ["aws_instance.cdh_worker"]
  provisioner "local-exec" {
    command = "echo ' cdh_workers ${join(",",aws_instance.cdh_worker.*.id)} ${join(",",aws_instance.cdh_worker.*.public_ip)}' >> inventory.txt"
  }
}
