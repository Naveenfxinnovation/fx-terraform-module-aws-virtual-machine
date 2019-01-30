output "id" {
  value = "${module.this.id}"
}

output "private_ip" {
  value = "${module.this.private_ip}"
}

output "public_ip" {
  value = "${module.this.public_ip}"
}

output "public_dns" {
  value = "${module.this.public_dns}"
}

output "private_dns" {
  value = "${module.this.private_dns}"
}

output "subnet_id" {
  value = "${module.this.subnet_id}"
}

output "availability_zone" {
  value = "${module.this.availability_zone}"
}

output "network_interface_id" {
  value = "${module.this.network_interface_id}"
}

output "primary_network_interface_id" {
  value = "${module.this.primary_network_interface_id}"
}

output "kms_key_id" {
  value = "${element(concat(aws_kms_key.this.*.id, list("")), 0)}"
}

output "external_volume_id" {
  value = "${element(concat(aws_ebs_volume.this.*.id, list("")), 0)}"
}

output "external_volume_arn" {
  value = "${element(concat(aws_ebs_volume.this.*.arn, list("")), 0)}"
}
