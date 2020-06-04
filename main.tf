locals {
  should_update_root_device = var.root_block_device_volume_type != null || var.root_block_device_volume_size != null || var.root_block_device_encrypted == true || var.root_block_device_iops != null
  use_incremental_names     = var.instance_count > 1 || (var.use_num_suffix && var.num_suffix_digits > 0)
  use_default_subnets       = var.instance_count > 0 && var.subnet_ids_count == 0

  used_subnet_count = floor(min(local.subnet_count, var.instance_count))

  subnet_count = local.use_default_subnets ? length(data.aws_subnet_ids.default.*.ids) : var.subnet_ids_count
  subnet_ids   = split(",", local.use_default_subnets ? join(",", tolist(element(concat(data.aws_subnet_ids.default.*.ids, [""]), 0))) : join(",", distinct(compact(concat([var.subnet_id], var.subnet_ids)))))
  vpc_id       = element(concat(data.aws_subnet.subnets.*.vpc_id, [""]), 0)

  tags = {
    Terraform  = true
    managed-by = "Terraform"
  }

  security_group_ids   = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : (tolist([data.aws_security_group.default.*.id]))
  iam_instance_profile = local.should_use_external_instance_profile ? var.iam_instance_profile_external_name : (local.should_create_instance_profile ? aws_iam_instance_profile.this.*.name[0] : null)
  kms_key_arn          = var.volume_kms_key_create ? aws_kms_key.this[0].arn : var.volume_kms_key_arn

  num_suffix_starting_index = var.num_suffix_offset + 1
}

####
# AutoScaling Group
####

resource "aws_launch_template" "this" {
  count = var.use_autoscaling_group && var.instance_count > 0 ? 1 : 0

  name          = local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.launch_template_name, count.index + local.num_suffix_starting_index) : var.launch_template_name
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = local.should_create_key_pair ? aws_key_pair.this.*.key_name[0] : var.key_pair_name

  user_data = var.user_data

  disable_api_termination = var.disable_api_termination

  ebs_optimized = var.ebs_optimized

  tags = merge(
    {
      "Name" = var.launch_template_name
    },
    var.tags,
    var.launch_template_tags,
    local.tags,
  )

  dynamic "cpu_options" {
    for_each = (var.cpu_threads_per_core != null || var.cpu_core_count != null) ? [1] : []

    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = local.is_t_instance_type && var.cpu_credits != null ? [1] : []

    content {
      cpu_credits = var.cpu_credits
    }
  }

  dynamic "block_device_mappings" {
    for_each = local.should_update_root_device ? [1] : []

    content {
      device_name = "/dev/sda1"

      ebs {
        delete_on_termination = true
        encrypted             = var.root_block_device_encrypted
        iops                  = var.root_block_device_iops
        volume_size           = var.root_block_device_volume_size
        volume_type           = var.root_block_device_volume_type
        kms_key_id            = local.kms_key_arn
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = data.null_data_source.ebs_block_device

    content {
      device_name = block_device_mappings.value.outputs.device_name

      ebs {
        delete_on_termination = true
        encrypted             = true
        volume_size           = lookup(block_device_mappings.value.outputs, "size", null)
        volume_type           = lookup(block_device_mappings.value.outputs, "type", null)
        kms_key_id            = local.kms_key_arn
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.ephemeral_block_devices

    content {
      device_name  = block_device_mappings.value.device_name
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
    }
  }

  dynamic "iam_instance_profile" {
    for_each = local.iam_instance_profile != null ? [1] : []

    content {
      name = local.iam_instance_profile
    }
  }

  dynamic "monitoring" {
    for_each = var.monitoring == true ? [1] : []

    content {
      enabled = true
    }
  }

  network_interfaces {
    security_groups             = local.security_group_ids[0]
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
  }

  dynamic "placement" {
    for_each = var.placement_group != null ? [1] : []

    content {
      availability_zone = data.aws_subnet.subnets.*.availability_zone[0]
      group_name        = var.placement_group
      tenancy           = var.tenancy
      host_id           = var.host_id
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        "Name" = local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.name, count.index + local.num_suffix_starting_index) : var.name
      },
      var.tags,
      var.instance_tags,
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        "Name" = var.external_volume_name
      },
      var.tags,
      var.external_volume_tags,
      local.tags,
    )
  }

  lifecycle {
    // credit_specification breaks idempotency (0.12.24 - AWS 2.59.0)
    ignore_changes = [
      credit_specification,
    ]
  }
}

resource "aws_autoscaling_group" "this" {
  count = var.use_autoscaling_group && var.instance_count > 0 ? 1 : 0

  name = (var.use_num_suffix && var.num_suffix_digits > 0) ? format("%s-%0${var.num_suffix_digits}d", var.autoscaling_group_name, count.index + local.num_suffix_starting_index) : var.autoscaling_group_name

  desired_capacity = var.instance_count
  max_size         = var.autoscaling_group_max_size
  min_size         = var.autoscaling_group_min_size

  health_check_grace_period = var.autoscaling_group_health_check_grace_period
  health_check_type         = var.autoscaling_group_health_check_type
  default_cooldown          = var.autoscaling_group_default_cooldown

  force_delete              = false
  wait_for_capacity_timeout = var.autoscaling_group_wait_for_capacity_timeout
  min_elb_capacity          = var.autoscaling_group_min_elb_capacity
  wait_for_elb_capacity     = var.autoscaling_group_wait_for_elb_capacity

  vpc_zone_identifier = data.aws_subnet.subnets.*.id

  launch_template {
    id      = aws_launch_template.this.*.id[0]
    version = aws_launch_template.this.*.latest_version[0]
  }

  termination_policies  = var.autoscaling_group_termination_policies
  suspended_processes   = var.autoscaling_group_suspended_processes
  metrics_granularity   = var.autoscaling_group_metrics_granularity
  enabled_metrics       = var.autoscaling_group_enabled_metrics
  max_instance_lifetime = var.autoscaling_group_max_instance_lifetime

  placement_group = var.placement_group

  dynamic "tag" {
    for_each = merge(var.tags, var.instance_tags, local.tags)

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.autoscaling_group_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_attachment" "this" {
  count = var.use_autoscaling_group && var.instance_count > 0 ? length(var.autoscaling_group_target_group_arns) : 0

  autoscaling_group_name = aws_autoscaling_group.this.*.id[0]
  alb_target_group_arn   = element(var.autoscaling_group_target_group_arns, count.index)
}

####
# EC2
####

locals {
  is_t_instance_type = replace(var.instance_type, "/^t[23]{1}\\..*$/", "1") == "1" ? "1" : "0"
}

resource "aws_instance" "this" {
  count = var.use_autoscaling_group ? 0 : var.instance_count

  ami           = var.ami
  instance_type = var.instance_type
  user_data     = var.user_data
  subnet_id     = element(data.aws_subnet.subnets.*.id, count.index)
  key_name      = local.should_create_key_pair ? aws_key_pair.this.*.key_name[0] : var.key_pair_name
  monitoring    = var.monitoring
  host_id       = var.host_id

  cpu_core_count       = var.cpu_core_count
  cpu_threads_per_core = var.cpu_threads_per_core

  vpc_security_group_ids = element(local.security_group_ids, count.index)
  iam_instance_profile   = local.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.ec2_private_ips != null ? element(concat(var.ec2_private_ips, [""]), count.index) : null
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ec2_ipv6_addresses

  ebs_optimized = var.ebs_optimized
  volume_tags = merge(
    {
      "Name" = local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.ec2_volume_name, count.index + (count.index * var.external_volume_count) + local.num_suffix_starting_index) : var.ec2_volume_name
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
      kms_key_id            = var.volume_kms_key_create ? aws_kms_key.this[0].arn : var.volume_kms_key_arn
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

  source_dest_check                    = var.ec2_source_dest_check
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
      "Name" = local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.name, count.index + local.num_suffix_starting_index) : var.name
    },
    var.tags,
    var.instance_tags,
    local.tags,
  )

  lifecycle {
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = [
      private_ip,
      root_block_device,
      volume_tags,
    ]
  }
}

####
# Instance Profile
####

locals {
  should_create_instance_profile       = var.instance_count > 0 && var.iam_instance_profile_create
  should_use_external_instance_profile = var.instance_count > 0 && var.iam_instance_profile_external_name != null
}

resource "aws_iam_instance_profile" "this" {
  count = local.should_create_instance_profile ? 1 : 0

  name = var.iam_instance_profile_name
  path = var.iam_instance_profile_path
  // “roles” is known to be deprecated over “role”
  // However, using “role” causes idempotency issue for now (terraform 0.12.24; AWS 2.59.0)
  roles = [aws_iam_role.this_instance_profile.*.id[0]]
}

resource "aws_iam_role" "this_instance_profile" {
  count = local.should_create_instance_profile ? 1 : 0

  name               = var.iam_instance_profile_iam_role_name
  description        = var.iam_instance_profile_iam_role_description
  path               = var.iam_instance_profile_path
  assume_role_policy = data.aws_iam_policy_document.sts_instance.*.json[0]

  tags = merge(
    var.tags,
    var.iam_instance_profile_iam_role_tags,
    local.tags,
  )
}

resource "aws_iam_role_policy_attachment" "this_instance_profile" {
  count = local.should_create_instance_profile ? var.iam_instance_profile_iam_role_policy_count : 0

  role       = aws_iam_role.this_instance_profile.*.id[0]
  policy_arn = element(var.iam_instance_profile_iam_role_policy_arns, count.index)
}

####
# Elastic IP
####

locals {
  should_create_elastic_ip                              = var.instance_count > 0 && var.eip_create && var.use_autoscaling_group == false
  should_create_elastic_ip_for_extra_network_interfaces = var.instance_count > 0 && var.extra_network_interface_eips_count > 0 && var.use_autoscaling_group == false

  network_interface_with_eip_ids = local.should_create_elastic_ip_for_extra_network_interfaces ? [
    for i, network_interface in aws_network_interface.this :
    network_interface.id
    if element(var.extra_network_interface_eips_enabled, i % var.extra_network_interface_count) == true
  ] : []
}

resource "aws_eip" "this" {
  count = local.should_create_elastic_ip ? var.instance_count : 0

  vpc = true
}

resource "aws_eip_association" "this" {
  count = local.should_create_elastic_ip ? var.instance_count : 0

  instance_id   = element(aws_instance.this.*.id, count.index)
  allocation_id = element(aws_eip.this.*.id, count.index)
}

resource "aws_eip" "extra" {
  count = local.should_create_elastic_ip_for_extra_network_interfaces ? var.instance_count * var.extra_network_interface_eips_count : 0

  vpc = true
}

resource "aws_eip_association" "extra" {
  count = local.should_create_elastic_ip ? var.instance_count * var.extra_network_interface_eips_count : 0

  network_interface_id = element(local.network_interface_with_eip_ids, count.index)
  allocation_id        = element(aws_eip.extra.*.id, count.index)
}

####
# Key Pair
####

locals {
  should_create_key_pair = var.instance_count > 0 && var.key_pair_create
}

resource "aws_key_pair" "this" {
  count = local.should_create_key_pair ? 1 : 0

  key_name   = var.key_pair_name
  public_key = var.key_pair_public_key
  tags = merge(
    var.tags,
    var.key_pair_tags,
    local.tags,
  )
}

####
# KMS
####

locals {
  should_create_kms_key = var.volume_kms_key_create && (var.root_block_device_encrypted || var.external_volume_count > 0) && var.use_autoscaling_group == false && var.instance_count > 0
}

resource "aws_kms_key" "this" {
  count = local.should_create_kms_key ? 1 : 0

  description              = "KMS key for ${var.name} instance(s) volume(s)."
  customer_master_key_spec = var.volume_kms_key_customer_master_key_spec
  policy                   = var.volume_kms_key_policy

  tags = merge(
    {
      "Name" = var.use_num_suffix == "true" ? format("%s-%0${var.num_suffix_digits}d", var.volume_kms_key_name, count.index + local.num_suffix_starting_index) : var.volume_kms_key_name
    },
    var.tags,
    var.volume_kms_key_tags,
    local.tags,
  )
}

resource "aws_kms_alias" "this" {
  count = local.should_create_kms_key ? 1 : 0

  name          = var.volume_kms_key_alias
  target_key_id = aws_kms_key.this[0].key_id
}

####
# EBS
####

locals {
  external_volume_use_incremental_names     = var.external_volume_count * var.instance_count > 1 || var.use_num_suffix == "true"
  should_create_extra_volumes               = var.external_volume_count > 0 && var.instance_count > 0 && var.use_autoscaling_group == false
  external_volume_num_suffix_starting_index = local.num_suffix_starting_index + var.external_volume_num_suffix_offset
}

resource "aws_volume_attachment" "this" {
  count = local.should_create_extra_volumes ? var.external_volume_count * var.instance_count : 0

  device_name = element(var.external_volume_device_names, count.index % var.external_volume_count)
  volume_id   = element(aws_ebs_volume.this.*.id, count.index)
  instance_id = element(aws_instance.this.*.id, floor(count.index / var.external_volume_count) % var.instance_count)
}

resource "aws_ebs_volume" "this" {
  count = local.should_create_extra_volumes ? var.external_volume_count * var.instance_count : 0

  availability_zone = element(data.aws_subnet.subnets.*.availability_zone, (floor(count.index / var.external_volume_count) % var.instance_count) % local.used_subnet_count)
  size              = element(var.external_volume_sizes, count.index % var.external_volume_count)
  type              = element(var.external_volume_types, count.index % var.external_volume_count)

  encrypted  = true
  kms_key_id = var.volume_kms_key_create ? element(aws_kms_key.this.*.arn, 0) : var.volume_kms_key_arn

  tags = merge(
    {
      "Name" = local.external_volume_use_incremental_names ? format(
        "%s-%0${var.num_suffix_digits}d",
        var.external_volume_name,
        count.index + (floor(count.index / var.external_volume_count) % var.instance_count) + local.external_volume_num_suffix_starting_index
      ) : var.external_volume_name
    },
    var.tags,
    var.external_volume_tags,
    local.tags,
  )
}

####
# Network Interfaces
####

locals {
  should_create_extra_network_interface      = var.extra_network_interface_count > 0 && var.use_autoscaling_group == false && var.instance_count > 0
  extra_network_interface_security_group_ids = var.extra_network_interface_security_group_ids == null ? local.security_group_ids : var.extra_network_interface_security_group_ids
}

resource "aws_network_interface" "this" {
  count = local.should_create_extra_network_interface ? var.extra_network_interface_count * var.instance_count : 0

  subnet_id         = element(data.aws_subnet.subnets.*.id, (floor(count.index / var.extra_network_interface_count) % var.instance_count) % local.used_subnet_count)
  private_ips       = element(var.extra_network_interface_private_ips, count.index % var.extra_network_interface_count)
  private_ips_count = element(var.extra_network_interface_private_ips_counts, count.index % var.extra_network_interface_count)
  source_dest_check = element(var.extra_network_interface_source_dest_checks, count.index % var.extra_network_interface_count)

  tags = merge(
    var.tags,
    var.extra_network_interface_tags,
    local.tags,
  )
}

resource "aws_network_interface_attachment" "this" {
  count = local.should_create_extra_network_interface ? var.extra_network_interface_count * var.instance_count : 0

  instance_id          = element(aws_instance.this.*.id, floor(count.index / var.extra_network_interface_count) % var.instance_count)
  network_interface_id = element(aws_network_interface.this.*.id, count.index)
  device_index         = (count.index % var.extra_network_interface_count) + 1
}

resource "aws_network_interface_sg_attachment" "this" {
  count = local.should_create_extra_network_interface ? var.extra_network_interface_security_group_count * var.instance_count * var.extra_network_interface_count : 0

  security_group_id = element(
    element(local.extra_network_interface_security_group_ids, floor(count.index / var.instance_count) % var.instance_count),
    count.index % var.extra_network_interface_security_group_count
  )
  network_interface_id = element(aws_network_interface.this.*.id, count.index % (var.instance_count * var.external_volume_count))
}
