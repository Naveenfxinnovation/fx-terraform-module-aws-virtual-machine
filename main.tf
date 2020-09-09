locals {
  should_update_root_device = var.root_block_device_volume_type != null || var.root_block_device_volume_size != null || var.root_block_device_encrypted == true || var.root_block_device_iops != null

  use_incremental_names     = var.use_num_suffix && var.num_suffix_digits > 0
  num_suffix_starting_index = var.num_suffix_offset + 1

  use_default_subnets = var.use_autoscaling_group ? var.autoscaling_group_subnet_ids_count == 0 : var.ec2_use_default_subnet

  subnet_ids         = var.use_autoscaling_group ? (local.use_default_subnets ? flatten(data.aws_subnet_ids.default.*.ids) : var.autoscaling_group_subnet_ids) : (local.use_default_subnets ? [flatten(data.aws_subnet_ids.default.*.ids)[0]] : [var.ec2_subnet_id])
  availability_zones = data.aws_subnet.current.*.availability_zone

  security_group_ids = local.should_fetch_default_security_group ? data.aws_security_group.default.*.id : var.vpc_security_group_ids

  ami = local.should_fetch_default_ami ? concat(data.aws_ssm_parameter.default_ami.*.value, [""])[0] : var.ami

  tags = {
    managed-by = "Terraform"
  }
}

####
# Launch Template
####

resource "aws_launch_template" "this" {
  count = var.use_autoscaling_group ? 1 : 0

  name = format("%s%s", var.prefix, var.launch_template_name)

  image_id      = local.ami
  instance_type = var.instance_type
  key_name      = local.key_pair_name

  user_data = var.user_data

  disable_api_termination = var.disable_api_termination

  ebs_optimized = var.ebs_optimized

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, var.launch_template_name)
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
      device_name = var.root_block_device_volume_device

      ebs {
        delete_on_termination = true
        encrypted             = var.root_block_device_encrypted
        iops                  = var.root_block_device_iops
        volume_size           = var.root_block_device_volume_size
        volume_type           = var.root_block_device_volume_type
        kms_key_id            = local.volume_kms_key_arn
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
        kms_key_id            = local.volume_kms_key_arn
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
    for_each = local.iam_instance_profile_name != null ? [1] : []

    content {
      name = local.iam_instance_profile_name
    }
  }

  dynamic "monitoring" {
    for_each = var.monitoring == true ? [1] : []

    content {
      enabled = true
    }
  }

  network_interfaces {
    description = format("%s%s", var.prefix, local.use_incremental_names ? "${format("%s-%0${var.num_suffix_digits}d", var.primary_network_interface_name, count.index + local.num_suffix_starting_index)} root network interface" : "${var.primary_network_interface_name} root network interface")

    security_groups             = local.security_group_ids
    associate_public_ip_address = var.associate_public_ip_address
    ipv6_address_count          = var.launch_template_ipv6_address_count
    ipv4_address_count          = var.ipv4_address_count
    delete_on_termination       = true
  }

  dynamic "placement" {
    for_each = var.placement_group != null ? [1] : []

    content {
      availability_zone = local.availability_zones[0]
      group_name        = var.placement_group
      tenancy           = var.tenancy
      host_id           = var.host_id
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        "Name" = format("%s%s", var.prefix, var.name)
      },
      var.tags,
      var.instance_tags,
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        "Name" = format("%s%s", var.prefix, local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.extra_volume_name, local.num_suffix_starting_index) : var.extra_volume_name)
      },
      var.tags,
      var.extra_volume_tags,
      local.tags,
    )
  }
}

####
# AutoScaling Group
####

resource "aws_autoscaling_group" "this" {
  count = var.use_autoscaling_group ? 1 : 0

  name = format("%s%s", var.prefix, var.autoscaling_group_name)

  desired_capacity = var.autoscaling_group_desired_capacity
  max_size         = var.autoscaling_group_max_size
  min_size         = var.autoscaling_group_min_size

  health_check_grace_period = var.autoscaling_group_health_check_grace_period == -1 ? null : var.autoscaling_group_health_check_grace_period
  health_check_type         = var.autoscaling_group_health_check_type
  default_cooldown          = var.autoscaling_group_default_cooldown == -1 ? null : var.autoscaling_group_default_cooldown

  force_delete              = false
  wait_for_capacity_timeout = var.autoscaling_group_wait_for_capacity_timeout
  min_elb_capacity          = var.autoscaling_group_min_elb_capacity
  wait_for_elb_capacity     = var.autoscaling_group_wait_for_elb_capacity

  vpc_zone_identifier = local.subnet_ids

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
  count = var.use_autoscaling_group ? length(var.autoscaling_group_target_group_arns) : 0

  autoscaling_group_name = aws_autoscaling_group.this.*.id[0]
  alb_target_group_arn   = element(var.autoscaling_group_target_group_arns, count.index)
}

resource "aws_autoscaling_schedule" "this" {
  count = var.use_autoscaling_group ? var.autoscaling_schedule_count : 0

  scheduled_action_name = local.use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.autoscaling_schedule_name, count.index + local.num_suffix_starting_index) : var.autoscaling_schedule_name
  min_size              = element(var.autoscaling_schedule_min_sizes, count.index)
  max_size              = element(var.autoscaling_schedule_max_sizes, count.index)
  desired_capacity      = element(var.autoscaling_schedule_desired_capacities, count.index)
  recurrence            = element(var.autoscaling_schedule_recurrences, count.index)
  start_time            = element(var.autoscaling_schedule_start_times, count.index) != null ? element(var.autoscaling_schedule_start_times, count.index) : timeadd(timestamp(), "1m")
  end_time              = element(var.autoscaling_schedule_end_times, count.index)

  autoscaling_group_name = aws_autoscaling_group.this.*.name[0]

  lifecycle {
    ignore_changes = [
      start_time,
    ]
  }
}

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
    ]
  }
}

####
# Instance Profile
####

locals {
  should_create_instance_profile = var.iam_instance_profile_create == true

  iam_instance_profile_name = local.should_create_instance_profile ? aws_iam_instance_profile.this.*.name[0] : var.iam_instance_profile_name
}

resource "aws_iam_instance_profile" "this" {
  count = local.should_create_instance_profile ? 1 : 0

  name = var.iam_instance_profile_name != null ? format("%s%s", var.prefix, var.iam_instance_profile_name) : null
  path = var.iam_instance_profile_path

  role = aws_iam_role.this_instance_profile.*.id[0]
}

resource "aws_iam_role" "this_instance_profile" {
  count = local.should_create_instance_profile ? 1 : 0

  name               = var.iam_instance_profile_iam_role_name != null ? format("%s%s", var.prefix, var.iam_instance_profile_iam_role_name) : null
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
  should_create_primary_eip                      = var.associate_public_ip_address == true && var.use_autoscaling_group == false
  should_create_eip_for_extra_network_interfaces = var.extra_network_interface_eips_count > 0 && var.use_autoscaling_group == false

  network_interface_with_eip_ids = local.should_create_eip_for_extra_network_interfaces ? [
    for i, network_interface in aws_network_interface.this_extra :
    network_interface.id
    if element(var.extra_network_interface_eips_enabled, i % var.extra_network_interface_count) == true
  ] : []
}

resource "aws_eip" "this_primary" {
  count = local.should_create_primary_eip ? 1 : 0

  vpc = true
}

resource "aws_eip_association" "this_primary" {
  count = local.should_create_primary_eip ? 1 : 0

  network_interface_id = aws_network_interface.this_primary.*.id[0]
  allocation_id        = aws_eip.this_primary.*.id[0]
}

resource "aws_eip" "this_extra" {
  count = local.should_create_eip_for_extra_network_interfaces ? var.extra_network_interface_eips_count : 0

  vpc = true
}

resource "aws_eip_association" "this_extra" {
  count = local.should_create_eip_for_extra_network_interfaces ? var.extra_network_interface_eips_count : 0

  network_interface_id = element(local.network_interface_with_eip_ids, count.index)
  allocation_id        = element(aws_eip.this_extra.*.id, count.index)
}

####
# Key Pair
####

locals {
  should_create_key_pair = var.key_pair_create

  key_pair_name = local.should_create_key_pair ? aws_key_pair.this.*.key_name[0] : var.key_pair_name
}

resource "aws_key_pair" "this" {
  count = local.should_create_key_pair ? 1 : 0

  key_name   = format("%s%s", var.prefix, var.key_pair_name)
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
  should_create_kms_key = var.volume_kms_key_create && (var.root_block_device_encrypted || var.extra_volume_count > 0)

  volume_kms_key_arn = local.should_create_kms_key ? aws_kms_key.this_volume.*.arn[0] : var.volume_kms_key_arn
}

resource "aws_kms_key" "this_volume" {
  count = local.should_create_kms_key ? 1 : 0

  description              = "KMS key for ${format("%s%s", var.prefix, var.name)} instance(s) volume(s)."
  customer_master_key_spec = var.volume_kms_key_customer_master_key_spec
  policy                   = var.volume_kms_key_policy

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, var.volume_kms_key_name)
    },
    var.tags,
    var.volume_kms_key_tags,
    local.tags,
  )
}

resource "aws_kms_alias" "this_extra_volume" {
  count = local.should_create_kms_key ? 1 : 0

  name          = format("alias/%s%s", var.prefix, var.volume_kms_key_alias)
  target_key_id = aws_kms_key.this_volume[0].key_id
}

####
# Extra EBS
####

locals {
  should_create_extra_volumes = var.extra_volume_count > 0 && var.use_autoscaling_group == false
}

resource "aws_volume_attachment" "this_extra" {
  count = local.should_create_extra_volumes ? var.extra_volume_count : 0

  device_name = element(var.extra_volume_device_names, count.index)
  volume_id   = element(aws_ebs_volume.this_extra.*.id, count.index)
  instance_id = aws_instance.this.*.id[0]
}

resource "aws_ebs_volume" "this_extra" {
  count = local.should_create_extra_volumes ? var.extra_volume_count : 0

  availability_zone = local.availability_zones[0]
  size              = element(var.extra_volume_sizes, count.index)
  type              = element(var.extra_volume_types, count.index)

  encrypted  = true
  kms_key_id = local.volume_kms_key_arn

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, local.use_incremental_names ? format(
        "%s-%0${var.num_suffix_digits}d",
        var.extra_volume_name,
        count.index + local.num_suffix_starting_index + 1
      ) : var.extra_volume_name)
    },
    var.tags,
    var.extra_volume_tags,
    local.tags,
  )
}

####
# Network Interfaces
####

locals {
  should_create_extra_network_interface             = var.extra_network_interface_count > 0 && var.use_autoscaling_group == false
  extra_network_interface_security_group_ids        = var.extra_network_interface_security_group_ids == null ? local.security_group_ids : var.extra_network_interface_security_group_ids
  extra_network_interface_num_suffix_starting_index = local.num_suffix_starting_index + var.extra_network_interface_num_suffix_offset
}

resource "aws_network_interface" "this_extra" {
  count       = local.should_create_extra_network_interface ? var.extra_network_interface_count : 0
  description = "Extra network interface ${count.index} for ${var.name} instance."

  subnet_id         = local.subnet_ids[0]
  private_ips       = element(var.extra_network_interface_private_ips, count.index)
  private_ips_count = element(var.extra_network_interface_private_ips_counts, count.index)
  source_dest_check = element(var.extra_network_interface_source_dest_checks, count.index)

  tags = merge(
    {
      "Name" = format("%s%s", var.prefix, local.use_incremental_names ? format(
        "%s-%0${var.num_suffix_digits}d",
        var.extra_network_interface_name,
        count.index + local.extra_network_interface_num_suffix_starting_index
      ) : var.extra_network_interface_name)
    },
    var.tags,
    var.extra_network_interface_tags,
    local.tags,
  )
}

resource "aws_network_interface_attachment" "this_extra" {
  count = local.should_create_extra_network_interface ? var.extra_network_interface_count : 0

  instance_id          = aws_instance.this.*.id[0]
  network_interface_id = aws_network_interface.this_extra.*.id[count.index]
  device_index         = count.index + 1
}

resource "aws_network_interface_sg_attachment" "this_extra" {
  count = local.should_create_extra_network_interface ? var.extra_network_interface_security_group_count * var.extra_network_interface_count : 0

  security_group_id    = element(local.extra_network_interface_security_group_ids, count.index)
  network_interface_id = element(aws_network_interface.this_extra.*.id, floor(count.index / var.extra_network_interface_security_group_count) % var.extra_network_interface_count)
}
