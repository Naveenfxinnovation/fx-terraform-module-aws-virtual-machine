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

  // This hack is necessary as for Terraform 0.13.2+ and AWS Provider 3.7.0+
  // Because aws_iam_service_linked_role resource returns a result before it's actually available, making ASG creation fail.
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

####
# AutoScaling Group
####

resource "aws_iam_service_linked_role" "asg" {
  count = var.use_autoscaling_group ? 1 : 0

  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = format("%s%s", var.prefix, var.autoscaling_group_name)
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

  service_linked_role_arn = aws_iam_service_linked_role.asg.*.arn[0]

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

  lifecycle {
    ignore_changes = [target_group_arns]
  }

  depends_on = [aws_iam_service_linked_role.asg]
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
