####
# AutoScaling Group
####

output "launch_configuration_id" {
  value = concat(aws_launch_configuration.this.*.id, [""])[0]
}

output "launch_configuration_arn" {
  value = concat(aws_launch_configuration.this.*.arn, [""])[0]
}

output "launch_configuration_name" {
  value = concat(aws_launch_configuration.this.*.name, [""])[0]
}

output "launch_configuration_ebs_block_devices" {
  value = concat(aws_launch_configuration.this.*.ebs_block_device, [""])[0]
}

output "autoscaling_group_id" {
  value = concat(aws_autoscaling_group.this.*.id, [""])[0]
}

output "autoscaling_group_arn" {
  value = concat(aws_autoscaling_group.this.*.arn, [""])[0]
}

output "autoscaling_group_availability_zones" {
  value = concat(aws_autoscaling_group.this.*.availability_zones, [""])[0]
}

####
# EC2
####

output "availability_zones" {
  value = compact(concat(aws_instance.this.*.availability_zone, [""]))
}

output "arns" {
  value = compact(concat(aws_instance.this.*.arn, [""]))
}

output "ids" {
  value = compact(concat(aws_instance.this.*.id, [""]))
}

output "private_ips" {
  value = compact(concat(aws_instance.this.*.private_ip, [""]))
}

output "primary_network_interface_ids" {
  value = compact(concat(aws_instance.this.*.primary_network_interface_id, [""]))
}

output "private_dns" {
  value = compact(concat(aws_instance.this.*.private_dns, [""]))
}

output "public_dns" {
  value = compact(concat(aws_instance.this.*.public_dns, [""]))
}

output "public_ips" {
  value = compact(concat(aws_instance.this.*.public_ip, [""]))
}

output "subnet_ids" {
  value = compact(concat(aws_instance.this.*.subnet_id, [""]))
}

####
# KMS
####

output "kms_key_id" {
  value = element(coalescelist([var.volume_kms_key_arn], aws_kms_key.this.*.arn), 0)
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
# EBS
####

output "external_volume_ids" {
  value = aws_ebs_volume.this.*.id
}

output "external_volume_arns" {
  value = aws_ebs_volume.this.*.arn
}
