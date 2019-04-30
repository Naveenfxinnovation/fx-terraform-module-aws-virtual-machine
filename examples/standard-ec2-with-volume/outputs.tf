output "availability_zones" {
  description = "Availability zones of the instances."
  value       = "${module.standard_ec2_with_volume.availability_zones}"
}

output "arns" {
  description = "Instance ARNs."
  value       = "${module.standard_ec2_with_volume.arns}"
}

output "credit_specifications" {
  description = "Credit specification of instance."
  value       = "${module.standard_ec2_with_volume.credit_specifications}"
}

output "ids" {
  description = "Instance IDs."
  value       = "${module.standard_ec2_with_volume.ids}"
}

output "private_ips" {
  description = "Private IPs of the instances."
  value       = "${module.standard_ec2_with_volume.private_ips}"
}

output "primary_network_interface_ids" {
  description = "The IDs of the instances primary network interfaces."
  value       = "${module.standard_ec2_with_volume.primary_network_interface_ids}"
}

output "private_dns" {
  description = "Private domain names of the instances."
  value       = "${module.standard_ec2_with_volume.private_dns}"
}

output "public_dns" {
  description = "Public domain names of the instances."
  value       = "${module.standard_ec2_with_volume.public_dns}"
}

output "public_ips" {
  description = "Public IPs of the instances."
  value       = "${module.standard_ec2_with_volume.public_ips}"
}

output "subnet_ids" {
  description = "The VPC subnet IDs where the instances are."
  value       = "${module.standard_ec2_with_volume.subnet_ids}"
}

output "kms_key_id" {
  description = "KMS key ID used to encrypt all the extra volumes."
  value       = "${module.standard_ec2_with_volume.kms_key_id}"
}

output "external_volume_ids" {
  description = "IDs of all the extra volumes."
  value       = "${module.standard_ec2_with_volume.external_volume_ids}"
}

output "external_volume_arns" {
  description = "ARNs of all the extra volumes."
  value       = "${module.standard_ec2_with_volume.external_volume_arns}"
}
