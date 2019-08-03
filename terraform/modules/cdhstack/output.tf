output "cdh_master" {
  value = "${aws_instance.cdh_master.*.public_ip}"
}

output "cdh_worker" {
  value = "${aws_instance.cdh_worker.*.public_ip}"
}