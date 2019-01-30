output "id" {
  value = "${module.standard_ec2_with_volume.id}"
}

output "private_ip" {
  value = "${module.standard_ec2_with_volume.private_ip}"
}

output "public_ip" {
  value = "${module.standard_ec2_with_volume.public_ip}"
}

output "public_dns" {
  value = "${module.standard_ec2_with_volume.public_dns}"
}

output "private_dns" {
  value = "${module.standard_ec2_with_volume.private_dns}"
}

output "subnet_id" {
  value = "${module.standard_ec2_with_volume.subnet_id}"
}

output "availability_zone" {
  value = "${module.standard_ec2_with_volume.availability_zone}"
}

output "network_interface_id" {
  value = "${module.standard_ec2_with_volume.network_interface_id}"
}

output "primary_network_interface_id" {
  value = "${module.standard_ec2_with_volume.primary_network_interface_id}"
}

output "kms_key_id" {
  value = "${module.standard_ec2_with_volume.kms_key_id}"
}

output "external_volume_id" {
  value = "${module.standard_ec2_with_volume.external_volume_id}"
}

output "external_volume_arn" {
  value = "${module.standard_ec2_with_volume.external_volume_arn}"
}
