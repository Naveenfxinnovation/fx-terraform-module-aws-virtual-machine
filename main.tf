locals {
  should_update_root_device = var.root_block_device_volume_type != null || var.root_block_device_volume_size != null || var.root_block_device_encrypted == true || var.root_block_device_iops != null
  use_incremental_names     = var.instance_count > 1 || (var.use_num_suffix && var.num_suffix_digits > 0)
  use_default_subnets       = var.subnet_ids_count == 0

  used_subnet_count = floor(min(local.subnet_count, var.instance_count))

  subnet_count = local.use_default_subnets ? length(data.aws_subnet_ids.default.ids) : var.subnet_ids_count
  subnet_ids   = split(",", local.use_default_subnets ? join(",", data.aws_subnet_ids.default.ids) : join(",", distinct(compact(concat([var.subnet_id], var.subnet_ids)))))
  vpc_id       = element(data.aws_subnet.subnets.*.vpc_id, 0)
}

####
# AutoScaling Group
####

resource "aws_launch_configuration" "this" {
  count = var.use_autoscaling_group && var.instance_count > 0 ? 1 : 0

  name_prefix = (var.use_num_suffix && var.num_suffix_digits > 0) ? format("%s%-0${var.num_suffix_digits}d", var.name, count.index + 1) : var.name

  image_id             = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  enable_monitoring    = var.monitoring

  security_groups = var.vpc_security_group_ids != null ? element(var.vpc_security_group_ids, count.index) : [data.aws_security_group.default.id]

  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data

  ebs_optimized = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = local.should_update_root_device ? [1] : [0]

    content {
      // Unlike EC2, launch configuration does not supporton-the-fly encryption of root device
      // Only device from encrypted snapshots can be encrypted
      delete_on_termination = true
      encrypted             = var.root_block_device_encrypted
      iops                  = var.root_block_device_iops
      volume_size           = var.root_block_device_volume_size
      volume_type           = var.root_block_device_volume_type
    }
  }

  dynamic "ebs_block_device" {
    for_each = data.null_data_source.ebs_block_device

    content {
      delete_on_termination = true
      encrypted             = true
      device_name           = ebs_block_device.value.outputs.device_name
      volume_size           = lookup(ebs_block_device.value.outputs, "size", null)
      volume_type           = lookup(ebs_block_device.value.outputs, "type", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_devices

    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  count = var.use_autoscaling_group && var.instance_count > 0 ? 1 : 0

  name = (var.use_num_suffix && var.num_suffix_digits > 0) ? format("%s%-0${var.num_suffix_digits}d", var.autoscaling_group_name, count.index + 1) : var.autoscaling_group_name

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

  launch_configuration = aws_launch_configuration.this.*.id[0]

  termination_policies  = var.autoscaling_group_termination_policies
  suspended_processes   = var.autoscaling_group_suspended_processes
  metrics_granularity   = var.autoscaling_group_metrics_granularity
  enabled_metrics       = var.autoscaling_group_enabled_metrics
  max_instance_lifetime = var.autoscaling_group_max_instance_lifetime

  placement_group = var.placement_group

  tag {
    key                 = "Terraform"
    value               = true
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

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

  dynamic "tag" {
    for_each = var.instance_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
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
  key_name      = var.key_name
  monitoring    = var.monitoring
  host_id       = var.ec2_host_id

  cpu_core_count       = var.ec2_cpu_core_count
  cpu_threads_per_core = var.ec2_cpu_threads_per_core

  vpc_security_group_ids = var.vpc_security_group_ids != null ? element(var.vpc_security_group_ids, count.index) : [data.aws_security_group.default.id]
  iam_instance_profile   = var.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.ec2_private_ips != null ? element(concat(var.ec2_private_ips, [""]), count.index) : null
  ipv6_address_count          = var.ec2_ipv6_address_count
  ipv6_addresses              = var.ec2_ipv6_addresses

  ebs_optimized = var.ebs_optimized
  volume_tags   = var.ec2_volume_tags

  dynamic "root_block_device" {
    for_each = local.should_update_root_device ? [1] : [0]

    content {
      delete_on_termination = true
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
  disable_api_termination              = var.ec2_disable_api_termination
  instance_initiated_shutdown_behavior = var.ec2_instance_initiated_shutdown_behavior
  placement_group                      = var.placement_group
  tenancy                              = var.ec2_tenancy

  dynamic "credit_specification" {
    for_each = local.is_t_instance_type ? [1] : [0]

    content {
      cpu_credits = var.ec2_cpu_credits
    }
  }

  tags = merge(
    {
      "Name" = local.use_incremental_names ? format("%s%-0${var.num_suffix_digits}d", var.name, count.index + 1) : var.name
    },
    var.tags,
    var.instance_tags,
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
      "Name" = var.use_num_suffix == "true" ? format("%s-%0${var.num_suffix_digits}d", var.volume_kms_key_name, count.index + 1) : var.volume_kms_key_name
    },
    {
      "Terraform" = "true"
    },
    var.tags,
    var.volume_kms_key_tags,
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
  external_volume_use_incremental_names = var.external_volume_count * var.instance_count > 1 || var.use_num_suffix == "true"
  should_create_extra_volumes           = var.external_volume_count > 0 && var.instance_count > 0 && var.use_autoscaling_group == false
}

resource "aws_volume_attachment" "this_ec2" {
  count = local.should_create_extra_volumes ? var.external_volume_count * var.instance_count : 0

  device_name = element(
    var.external_volume_device_names,
    floor(count.index / var.instance_count) % var.external_volume_count,
  )
  volume_id   = element(aws_ebs_volume.this.*.id, count.index)
  instance_id = element(aws_instance.this.*.id, count.index % var.instance_count)
}

resource "aws_ebs_volume" "this" {
  count = local.should_create_extra_volumes ? var.external_volume_count * var.instance_count : 0

  availability_zone = element(data.aws_subnet.subnets.*.availability_zone, count.index % local.used_subnet_count)
  size = element(
    var.external_volume_sizes,
    floor(count.index / var.instance_count) % var.external_volume_count,
  )
  type = element(
    var.external_volume_types,
    floor(count.index / var.instance_count) % var.external_volume_count,
  )

  encrypted  = true
  kms_key_id = var.volume_kms_key_create ? element(aws_kms_key.this.*.arn, 0) : var.volume_kms_key_arn

  tags = merge(
    {
      "Name" = local.external_volume_use_incremental_names ? format("%s-%0${var.num_suffix_digits}d", var.external_volume_name, count.index + 1) : var.external_volume_name
    },
    {
      "Terraform" = "true"
    },
    var.tags,
    var.external_volume_tags,
  )
}
