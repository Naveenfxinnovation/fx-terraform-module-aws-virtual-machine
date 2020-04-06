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

output "availability_zones" {
  value = module.example.availability_zones
}

output "arns" {
  value = module.example.arns
}

output "credit_specifications" {
  value = module.example.credit_specifications
}

output "ids" {
  value = module.example.ids
}

output "private_ips" {
  value = module.example.private_ips
}

output "primary_network_interface_ids" {
  value = module.example.primary_network_interface_ids
}

output "private_dns" {
  value = module.example.private_dns
}

output "public_dns" {
  value = module.example.public_dns
}

output "public_ips" {
  value = module.example.public_ips
}

output "subnet_ids" {
  value = module.example.subnet_ids
}

output "kms_key_id" {
  value = module.example.kms_key_id
}

output "external_volume_ids" {
  value = module.example.external_volume_ids
}

output "external_volume_arns" {
  value = module.example.external_volume_arns
}
