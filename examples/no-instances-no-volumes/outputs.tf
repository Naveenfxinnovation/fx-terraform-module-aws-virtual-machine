####
# Global
####

output "availability_zones" {
  value = module.example.availability_zones
}

output "subnet_ids" {
  value = module.example.subnet_ids
}

####
# Launch template
####

output "launch_template_id" {
  value = module.example.launch_template_id
}

output "launch_template_arn" {
  value = module.example.launch_template_arn
}

output "launch_template_default_version" {
  value = module.example.launch_template_default_version
}

output "launch_template_latest_version" {
  value = module.example.launch_template_latest_version
}

####
# AutoScaling Group
####

output "autoscaling_group_id" {
  value = module.example.autoscaling_group_id
}

output "autoscaling_group_arn" {
  value = module.example.autoscaling_group_arn
}

####
# EC2
####

output "ec2_arns" {
  value = module.example.ec2_arns
}

output "ec2_ids" {
  value = module.example.ec2_ids
}

output "ec2_private_ips" {
  value = module.example.ec2_private_ips
}

output "ec2_primary_network_interface_ids" {
  value = module.example.ec2_primary_network_interface_ids
}

output "ec2_private_dns" {
  value = module.example.ec2_private_dns
}

output "ec2_public_dns" {
  value = module.example.ec2_public_dns
}

output "ec2_public_ips" {
  value = module.example.ec2_public_ips
}

####
# KMS
####

output "kms_key_id" {
  value = module.example.kms_key_id
}

####
# Instance Profile
####

output "iam_instance_profile_id" {
  value = module.example.iam_instance_profile_id
}

output "iam_instance_profile_arn" {
  value = module.example.iam_instance_profile_arn
}

output "iam_instance_profile_unique_id" {
  value = module.example.iam_instance_profile_unique_id
}

output "iam_instance_profile_iam_role_arn" {
  value = module.example.iam_instance_profile_iam_role_arn
}

output "iam_instance_profile_iam_role_id" {
  value = module.example.iam_instance_profile_iam_role_id
}

output "iam_instance_profile_iam_role_unique_id" {
  value = module.example.iam_instance_profile_iam_role_unique_id
}

####
# Key Pair
####

output "key_pair_name" {
  value = module.example.key_pair_name
}

output "key_pair_id" {
  value = module.example.key_pair_id
}

output "key_pair_fingerprint" {
  value = module.example.key_pair_fingerprint
}

####
# Elastic IP
####

output "eip_ids" {
  value = module.example.eip_ids
}

output "eip_private_ips" {
  value = module.example.eip_private_ips
}

output "eip_private_dns" {
  value = module.example.eip_private_dns
}

output "eip_public_ips" {
  value = module.example.eip_public_ips
}

output "eip_public_dns" {
  value = module.example.eip_public_dns
}

output "eip_network_interfaces" {
  value = module.example.eip_network_interfaces
}

####
# EBS
####

output "external_volume_ids" {
  value = module.example.external_volume_ids
}

output "external_volume_arns" {
  value = module.example.external_volume_arns
}

####
# Network Interfaces
####

output "extra_network_interface_ids" {
  value = module.example.extra_network_interface_ids
}

output "extra_network_interface_mac_addresses" {
  value = module.example.extra_network_interface_mac_addresses
}

output "extra_network_interface_private_ips" {
  value = module.example.extra_network_interface_private_ips
}

output "extra_network_interface_public_ips" {
  value = module.example.extra_network_interface_public_ips
}
