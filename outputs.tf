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
# Launch template
####

output "launch_template_id" {
  value = concat(aws_launch_template.this.*.id, [""])[0]
}

output "launch_template_arn" {
  value = concat(aws_launch_template.this.*.arn, [""])[0]
}

output "launch_template_default_version" {
  value = concat(aws_launch_template.this.*.default_version, [""])[0]
}

output "launch_template_latest_version" {
  value = concat(aws_launch_template.this.*.latest_version, [""])[0]
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

output "ec2_arn" {
  value = concat(aws_instance.this.*.arn, [""])[0]
}

output "ec2_id" {
  value = concat(aws_instance.this.*.id, [""])[0]
}

output "ec2_private_ip" {
  value = concat(aws_instance.this.*.private_ip, [""])[0]
}

output "ec2_primary_network_interface_id" {
  value = concat(aws_instance.this.*.primary_network_interface_id, [""])[0]
}

output "ec2_private_dns" {
  value = concat(aws_instance.this.*.private_dns, [""])[0]
}

output "ec2_public_dns" {
  value = concat(aws_instance.this.*.public_dns, [""])[0]
}

output "ec2_public_ip" {
  value = concat(aws_instance.this.*.public_ip, [""])[0]
}

####
# KMS
####

output "kms_key_id" {
  value = concat([var.volume_kms_key_arn], aws_kms_key.this_volume.*.arn, [""])[0]
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
  value = {
    primary = aws_eip.this_primary.*.id
    extra   = aws_eip.this_extra.*.id
  }
}

// Commented Until this is fixed: https://github.com/terraform-providers/terraform-provider-aws/issues/15093
// Use ec2_private_ip instead
//output "eip_private_ips" {
//  value = {
//    primary = aws_eip.this_primary.*.private_ip
//    extra   = aws_eip.this_extra.*.private_ip
//  }
//}

// Commented Until this is fixed: https://github.com/terraform-providers/terraform-provider-aws/issues/15093
// Use ec2_private_dns instead
//output "eip_private_dns" {
//  value = {
//    primary = aws_eip.this_primary.*.private_dns
//    extra   = aws_eip.this_extra.*.private_dns
//  }
//}

output "eip_public_ips" {
  value = {
    primary = aws_eip.this_primary.*.public_ip
    extra   = aws_eip.this_extra.*.public_ip
  }
}

output "eip_public_dns" {
  value = {
    primary = aws_eip.this_primary.*.public_dns
    extra   = aws_eip.this_extra.*.public_dns
  }
}

// Commented Until this is fixed: https://github.com/terraform-providers/terraform-provider-aws/issues/15093
// Use ec2_primary_network_interface_id and network_interface_ids instead
//output "eip_network_interfaces" {
//  value = {
//    primary = aws_eip.this_primary.*.network_interface
//    extra   = aws_eip.this_extra.*.network_interface
//  }
//}

####
# EBS
####

output "extra_volume_ids" {
  value = aws_ebs_volume.this_extra.*.id
}

output "extra_volume_arns" {
  value = aws_ebs_volume.this_extra.*.arn
}

####
# Network Interfaces
####

output "network_interface_ids" {
  value = {
    primary = aws_network_interface.this_primary.*.id
    extra   = aws_network_interface.this_extra.*.id
  }
}

output "network_interface_mac_addresses" {
  value = {
    primary = aws_network_interface.this_primary.*.mac_address
    extra   = aws_network_interface.this_extra.*.mac_address
  }
}

output "network_interface_private_ips" {
  value = {
    primary = aws_network_interface.this_primary.*.private_ips
    extra   = aws_network_interface.this_extra.*.private_ips
  }
}
