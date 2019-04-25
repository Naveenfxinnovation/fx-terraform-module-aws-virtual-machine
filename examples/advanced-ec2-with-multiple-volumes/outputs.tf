output "ids" {
  value = "${module.advanced_ec2_with_multiple_volumes.ids}"
}

output "private_ips" {
  value = "${module.advanced_ec2_with_multiple_volumes.private_ips}"
}

output "public_ips" {
  value = "${module.advanced_ec2_with_multiple_volumes.public_ips}"
}

output "public_dns" {
  value = "${module.advanced_ec2_with_multiple_volumes.public_dns}"
}

output "private_dns" {
  value = "${module.advanced_ec2_with_multiple_volumes.private_dns}"
}

output "subnet_ids" {
  value = "${module.advanced_ec2_with_multiple_volumes.subnet_ids}"
}

output "availability_zone" {
  value = "${module.advanced_ec2_with_multiple_volumes.availability_zone}"
}

output "primary_network_interface_ids" {
  value = "${module.advanced_ec2_with_multiple_volumes.primary_network_interface_ids}"
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
