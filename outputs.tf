####
# Global
####

output "availability_zones" {
  value = compact(concat(aws_instance.this.*.availability_zone, tolist(element(concat(aws_autoscaling_group.this.*.availability_zones, [[""]]), 0)), [""]))
}

output "subnet_ids" {
  value = compact(concat(aws_instance.this.*.subnet_id, tolist(element(concat(aws_autoscaling_group.this.*.vpc_zone_identifier, [[""]]), 0)), [""]))
}

####
# AutoScaling Group
####

output "autoscaling_group_id" {
  value = concat(aws_autoscaling_group.this.*.id, [""])[0]
}

output "autoscaling_group_arn" {
  value = concat(aws_autoscaling_group.this.*.arn, [""])[0]
}

####
# EC2
####

output "ec2_arns" {
  value = compact(concat(aws_instance.this.*.arn, [""]))
}

output "ec2_ids" {
  value = compact(concat(aws_instance.this.*.id, [""]))
}

output "ec2_private_ips" {
  value = compact(concat(aws_instance.this.*.private_ip, [""]))
}

output "ec2_primary_network_interface_ids" {
  value = compact(concat(aws_instance.this.*.primary_network_interface_id, [""]))
}

output "ec2_private_dns" {
  value = compact(concat(aws_instance.this.*.private_dns, [""]))
}

output "ec2_public_dns" {
  value = compact(concat(aws_instance.this.*.public_dns, [""]))
}

output "ec2_public_ips" {
  value = compact(concat(aws_instance.this.*.public_ip, [""]))
}

####
# KMS
####

output "kms_key_id" {
  value = element(coalescelist([var.volume_kms_key_arn], aws_kms_key.this.*.arn), 0)
}

####
# Instance Profile
####

output "iam_instance_profile_id" {
  value = local.should_create_instance_profile ? concat(aws_iam_instance_profile.this.*.id, [""])[0] : ""
}

output "iam_instance_profile_arn" {
  value = local.should_create_instance_profile ? concat(aws_iam_instance_profile.this.*.arn, [""])[0] : ""
}

output "iam_instance_profile_unique_id" {
  value = local.should_create_instance_profile ? concat(aws_iam_instance_profile.this.*.unique_id, [""])[0] : ""
}

output "iam_instance_profile_iam_role_arn" {
  value = local.should_create_instance_profile ? concat(aws_iam_role.this_instance_profile.*.arn, [""])[0] : ""
}

output "iam_instance_profile_iam_role_id" {
  value = local.should_create_key_pair ? concat(aws_iam_role.this_instance_profile.*.id, [""])[0] : ""
}

output "iam_instance_profile_iam_role_unique_id" {
  value = local.should_create_key_pair ? concat(aws_iam_role.this_instance_profile.*.unique_id, [""])[0] : ""
}

####
# Key Pair
####

output "key_pair_name" {
  value = local.should_create_key_pair ? concat(aws_key_pair.this.*.key_name, [""])[0] : ""
}

output "key_pair_id" {
  value = concat(aws_key_pair.this.*.id, [""])[0]
}

output "key_pair_fingerprint" {
  value = concat(aws_key_pair.this.*.fingerprint, [""])[0]
}

####
# Elastic IP
####

output "eip_ids" {
  value = aws_eip.this.*.id
}

output "eip_private_ips" {
  value = aws_eip.this.*.private_ip
}

output "eip_private_dns" {
  value = aws_eip.this.*.private_dns
}

output "eip_public_ips" {
  value = aws_eip.this.*.public_ip
}

output "eip_public_dns" {
  value = aws_eip.this.*.public_dns
}

output "eip_network_interfaces" {
  value = aws_eip.this.*.network_interface
}

####
# EBS
####

output "external_volume_ids" {
  value = local.should_create_extra_volumes ? zipmap(aws_instance.this.*.id, chunklist(compact(concat(aws_ebs_volume.this.*.id, [""])), var.external_volume_count)) : {}
}

output "external_volume_arns" {
  value = local.should_create_extra_volumes ? zipmap(aws_instance.this.*.id, chunklist(compact(concat(aws_ebs_volume.this.*.arn, [""])), var.external_volume_count)) : {}
}

####
# Network Interfaces
####

output "extra_network_interface_ids" {
  value = local.should_create_extra_network_interface ? zipmap(aws_instance.this.*.id, chunklist(compact(concat(aws_network_interface.this.*.id, [""])), var.extra_network_interface_count)) : {}
}

output "extra_network_interface_mac_addresses" {
  value = local.should_create_extra_network_interface ? zipmap(aws_instance.this.*.id, chunklist(compact(concat(aws_network_interface.this.*.mac_address, [""])), var.extra_network_interface_count)) : {}
}

output "extra_network_interface_private_ips" {
  value = local.should_create_extra_network_interface ? zipmap(aws_instance.this.*.id, chunklist(aws_network_interface.this.*.private_ips, var.extra_network_interface_count)) : {}
}

output "extra_network_interface_public_ips" {
  value = local.should_create_extra_network_interface && var.extra_network_interface_eips_count > 0 ? zipmap(aws_instance.this.*.id, chunklist(aws_eip.extra.*.public_ip, var.extra_network_interface_eips_count)) : {}
}
