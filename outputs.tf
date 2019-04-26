output "ids" {
  value = "${concat(module.this.id, list(""))}"
}

output "private_ips" {
  value = "${concat(module.this.private_ip, list(""))}"
}

output "public_ips" {
  value = "${concat(module.this.public_ip, list(""))}"
}

output "public_dns" {
  value = "${concat(module.this.public_dns, list(""))}"
}

output "private_dns" {
  value = "${concat(module.this.private_dns, list(""))}"
}

output "subnet_ids" {
  value = "${concat(module.this.subnet_id, list(""))}"
}

output "availability_zones" {
  value = "${concat(module.this.availability_zone, list(""))}"
}

output "primary_network_interface_ids" {
  value = "${concat(module.this.primary_network_interface_id, list(""))}"
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
