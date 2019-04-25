output "ids" {
  value = "${module.standard_ec2_with_volume.ids}"
}

output "private_ips" {
  value = "${module.standard_ec2_with_volume.private_ips}"
}

output "public_ips" {
  value = "${module.standard_ec2_with_volume.public_ips}"
}

output "public_dns" {
  value = "${module.standard_ec2_with_volume.public_dns}"
}

output "private_dns" {
  value = "${module.standard_ec2_with_volume.private_dns}"
}

output "subnet_ids" {
  value = "${module.standard_ec2_with_volume.subnet_ids}"
}

output "availability_zone" {
  value = "${module.standard_ec2_with_volume.availability_zone}"
}

output "primary_network_interface_ids" {
  value = "${module.standard_ec2_with_volume.primary_network_interface_ids}"
}

output "kms_key_id" {
  value = "${module.standard_ec2_with_volume.kms_key_id}"
}

output "external_volume_ids" {
  value = "${module.standard_ec2_with_volume.external_volume_ids}"
}

output "external_volume_arns" {
  value = "${module.standard_ec2_with_volume.external_volume_arns}"
}
