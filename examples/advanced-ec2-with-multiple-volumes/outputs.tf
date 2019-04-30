output "availability_zones" {
  description = "Availability zones of the instances."
  value       = "${module.advanced_ec2_with_multiple_volumes.availability_zones}"
}

output "arns" {
  description = "Instance ARNs."
  value       = "${module.advanced_ec2_with_multiple_volumes.arns}"
}

output "credit_specifications" {
  description = "Credit specification of instance."
  value       = "${module.advanced_ec2_with_multiple_volumes.credit_specifications}"
}

output "ids" {
  description = "Instance IDs."
  value       = "${module.advanced_ec2_with_multiple_volumes.ids}"
}

output "private_ips" {
  description = "Private IPs of the instances."
  value       = "${module.advanced_ec2_with_multiple_volumes.private_ips}"
}

output "primary_network_interface_ids" {
  description = "The IDs of the instances primary network interfaces."
  value       = "${module.advanced_ec2_with_multiple_volumes.primary_network_interface_ids}"
}

output "private_dns" {
  description = "Private domain names of the instances."
  value       = "${module.advanced_ec2_with_multiple_volumes.private_dns}"
}

output "public_dns" {
  description = "Public domain names of the instances."
  value       = "${module.advanced_ec2_with_multiple_volumes.public_dns}"
}

output "public_ips" {
  description = "Public IPs of the instances."
  value       = "${module.advanced_ec2_with_multiple_volumes.public_ips}"
}

output "subnet_ids" {
  description = "The VPC subnet IDs where the instances are."
  value       = "${module.advanced_ec2_with_multiple_volumes.subnet_ids}"
}

output "kms_key_id" {
  description = "KMS key ID used to encrypt all the extra volumes."
  value       = "${module.advanced_ec2_with_multiple_volumes.kms_key_id}"
}

output "external_volume_ids" {
  description = "IDs of all the extra volumes."
  value       = "${module.advanced_ec2_with_multiple_volumes.external_volume_ids}"
}

output "external_volume_arns" {
  description = "ARNs of all the extra volumes."
  value       = "${module.advanced_ec2_with_multiple_volumes.external_volume_arns}"
}
