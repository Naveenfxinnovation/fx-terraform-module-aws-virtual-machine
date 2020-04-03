####
# EC2
####

output "availability_zones" {
  description = "Availability zones of the instances."
  value = compact(
    concat(
      aws_instance.this.*.availability_zone,
      aws_instance.this_t.*.availability_zone,
      [""],
    ),
  )
}

output "arns" {
  description = "Instance ARNs."
  value = compact(
    concat(aws_instance.this.*.arn, aws_instance.this_t.*.arn, [""]),
  )
}

output "credit_specifications" {
  description = "Credit specification of instance."
  value       = aws_instance.this_t.*.credit_specification
}

output "ids" {
  description = "Instance IDs."
  value = compact(
    concat(aws_instance.this.*.id, aws_instance.this_t.*.id, [""]),
  )
}

output "private_ips" {
  description = "Private IPs of the instances."
  value = compact(
    concat(
      aws_instance.this.*.private_ip,
      aws_instance.this_t.*.private_ip,
      [""],
    ),
  )
}

output "primary_network_interface_ids" {
  description = "The IDs of the instances primary network interfaces."
  value = compact(
    concat(
      aws_instance.this.*.primary_network_interface_id,
      aws_instance.this_t.*.primary_network_interface_id,
      [""],
    ),
  )
}

output "private_dns" {
  description = "Private domain names of the instances."
  value = compact(
    concat(
      aws_instance.this.*.private_dns,
      aws_instance.this_t.*.private_dns,
      [""],
    ),
  )
}

output "public_dns" {
  description = "Public domain names of the instances."
  value = compact(
    concat(
      aws_instance.this.*.public_dns,
      aws_instance.this_t.*.public_dns,
      [""],
    ),
  )
}

output "public_ips" {
  description = "Public IPs of the instances."
  value = compact(
    concat(
      aws_instance.this.*.public_ip,
      aws_instance.this_t.*.public_ip,
      [""],
    ),
  )
}

output "subnet_ids" {
  description = "The VPC subnet IDs where the instances are."
  value = compact(
    concat(
      aws_instance.this.*.subnet_id,
      aws_instance.this_t.*.subnet_id,
      [""],
    ),
  )
}

####
# Extra volumes
####

output "kms_key_id" {
  description = "KMS key ID (ARN) used to encrypt all the extra volumes."
  value = element(
    coalescelist([var.volume_kms_key_arn], aws_kms_key.this.*.arn),
    0,
  )
}

output "external_volume_ids" {
  description = "IDs of all the extra volumes."
  value       = aws_ebs_volume.this.*.id
}

output "external_volume_arns" {
  description = "ARNs of all the extra volumes."
  value       = aws_ebs_volume.this.*.arn
}
