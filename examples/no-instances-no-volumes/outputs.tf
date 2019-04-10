output "ids" {
  value = "${module.no_instances_no_volumes.ids}"
}

output "private_ips" {
  value = "${module.no_instances_no_volumes.private_ips}"
}

output "public_ips" {
  value = "${module.no_instances_no_volumes.public_ips}"
}

output "public_dns" {
  value = "${module.no_instances_no_volumes.public_dns}"
}

output "private_dns" {
  value = "${module.no_instances_no_volumes.private_dns}"
}

output "subnet_id" {
  value = "${module.no_instances_no_volumes.subnet_id}"
}

output "availability_zone" {
  value = "${module.no_instances_no_volumes.availability_zone}"
}

output "primary_network_interface_ids" {
  value = "${module.no_instances_no_volumes.primary_network_interface_ids}"
}

output "kms_key_id" {
  value = "${module.no_instances_no_volumes.kms_key_id}"
}

output "external_volume_ids" {
  value = "${module.no_instances_no_volumes.external_volume_ids}"
}

output "external_volume_arns" {
  value = "${module.no_instances_no_volumes.external_volume_arns}"
}
