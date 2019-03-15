output "id" {
  value = "${module.advanced_ec2_with_multiple_volumes.id}"
}

output "private_ip" {
  value = "${module.advanced_ec2_with_multiple_volumes.private_ip}"
}

output "public_ip" {
  value = "${module.advanced_ec2_with_multiple_volumes.public_ip}"
}

output "public_dns" {
  value = "${module.advanced_ec2_with_multiple_volumes.public_dns}"
}

output "private_dns" {
  value = "${module.advanced_ec2_with_multiple_volumes.private_dns}"
}

output "subnet_id" {
  value = "${module.advanced_ec2_with_multiple_volumes.subnet_id}"
}

output "availability_zone" {
  value = "${module.advanced_ec2_with_multiple_volumes.availability_zone}"
}

output "primary_network_interface_id" {
  value = "${module.advanced_ec2_with_multiple_volumes.primary_network_interface_id}"
}

output "kms_key_id" {
  value = "${module.advanced_ec2_with_multiple_volumes.kms_key_id}"
}

output "external_volume_ids" {
  value = "${module.advanced_ec2_with_multiple_volumes.external_volume_ids}"
}

output "external_volume_arns" {
  value = "${module.advanced_ec2_with_multiple_volumes.external_volume_arns}"
}
