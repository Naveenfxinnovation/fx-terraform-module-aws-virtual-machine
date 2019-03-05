output "id" {
  value = "${element(concat(module.this.id, list("")), 0)}"
}

output "private_ip" {
  value = "${element(concat(module.this.private_ip, list("")), 0)}"
}

output "public_ip" {
  value = "${element(concat(module.this.public_ip, list("")), 0)}"
}

output "public_dns" {
  value = "${element(concat(module.this.public_dns, list("")), 0)}"
}

output "private_dns" {
  value = "${element(concat(module.this.private_dns, list("")), 0)}"
}

output "subnet_id" {
  value = "${element(concat(module.this.subnet_id, list("")), 0)}"
}

output "availability_zone" {
  value = "${element(concat(module.this.availability_zone, list("")), 0)}"
}

output "primary_network_interface_id" {
  value = "${element(concat(module.this.primary_network_interface_id, list("")), 0)}"
}

output "kms_key_id" {
  value = "${element(concat(aws_kms_key.this.*.id, list("")), 0)}"
}

output "external_volume_ids" {
  value = "${aws_ebs_volume.this.*.id}"
}

output "external_volume_arns" {
  value = "${aws_ebs_volume.this.*.arn}"
}
