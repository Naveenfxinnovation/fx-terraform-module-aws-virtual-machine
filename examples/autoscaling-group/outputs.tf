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
# AutoScaling Group
####

output "launch_configuration_id" {
  value = module.example.launch_configuration_id
}

output "launch_configuration_arn" {
  value = module.example.launch_configuration_arn
}

output "launch_configuration_name" {
  value = module.example.launch_configuration_name
}

output "launch_configuration_ebs_block_devices" {
  value = module.example.launch_configuration_ebs_block_devices
}

output "autoscaling_group_id" {
  value = module.example.autoscaling_group_id
}

output "autoscaling_group_arn" {
  value = module.example.autoscaling_group_arn
}

output "autoscaling_group_availability_zones" {
  value = module.example.autoscaling_group_availability_zones
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
