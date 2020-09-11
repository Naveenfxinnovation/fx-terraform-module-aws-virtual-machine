####
# EC2
####

locals {
  is_t_instance_type = replace(var.instance_type, "/^t[23]{1}\\..*$/", "1") == "1" ? "1" : "0"
}

resource "aws_instance" "this" {
  count = var.use_autoscaling_group ? 0 : 1

  ami           = local.ami
  instance_type = var.instance_type
  user_data     = var.user_data
  key_name      = local.key_pair_name
  monitoring    = var.monitoring
  host_id       = var.host_id

  cpu_core_count       = var.cpu_core_count
  cpu_threads_per_core = var.cpu_threads_per_core

  network_interface {
    device_index         = 0
    network_interface_id = local.primary_eni_id
  }

  iam_instance_profile = local.iam_instance_profile_name

  ebs_optimized = var.ebs_optimized
  volume_tags = merge(
    {
      "Name" = format("%s%s", var.prefix, local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.ec2_volume_name, count.index + (count.index * var.extra_volume_count) + local.num_suffix_starting_index) : var.ec2_volume_name)
    },
    var.tags,
    var.ec2_volume_tags,
    local.tags,
  )

  dynamic "root_block_device" {
    for_each = local.should_update_root_device ? [1] : []

    content {
      delete_on_termination = var.root_block_device_delete_on_termination
      encrypted             = var.root_block_device_encrypted
      iops                  = var.root_block_device_iops
      volume_size           = var.root_block_device_volume_size
      volume_type           = var.root_block_device_volume_type
      kms_key_id            = local.volume_kms_key_arn
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_devices

    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy

  dynamic "credit_specification" {
    for_each = local.is_t_instance_type && var.cpu_credits != null ? [1] : []

    content {
      cpu_credits = var.cpu_credits
    }
  }

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, var.name)
    },
    var.tags,
    var.instance_tags,
    local.tags,
  )

  lifecycle {
    ignore_changes = [
      private_ip,
      root_block_device,
      volume_tags,
    ]
  }
}

locals {
  should_create_primary_eni = var.use_autoscaling_group == false && var.ec2_primary_network_interface_create

  primary_eni_id = local.should_create_primary_eni ? aws_network_interface.this_primary.*.id[0] : var.ec2_external_primary_network_interface_id
}

resource "aws_network_interface" "this_primary" {
  count = local.should_create_primary_eni ? 1 : 0

  description     = format("%s%s", var.prefix, local.use_incremental_names ? "${format("%s-%0${var.num_suffix_digits}d", var.name, count.index + local.num_suffix_starting_index)} root network interface" : "${var.name} root network interface")
  subnet_id       = local.subnet_ids[0]
  security_groups = local.security_group_ids

  private_ips_count = var.ipv4_address_count
  private_ips       = concat(var.ec2_ipv6_addresses, var.ec2_ipv4_addresses)

  source_dest_check = var.ec2_source_dest_check

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, local.use_incremental_names ? format(
        "%s-%0${var.num_suffix_digits}d",
        var.primary_network_interface_name,
        count.index + (count.index * var.extra_network_interface_count) + local.num_suffix_starting_index
      ) : var.primary_network_interface_name)
    },
    var.tags,
    var.ec2_network_interface_tags,
    local.tags,
  )

  lifecycle {
    ignore_changes = [
      private_ips,
      private_ips_count
    ]
  }
}
