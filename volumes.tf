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
  iops              = contains(["io1", "io2", "gp3"], element(var.extra_volume_types, count.index)) ? element(var.extra_volume_iops, count.index) : null
  throughput        = element(var.extra_volume_types, count.index) == "gp3" ? element(var.extra_volume_throughput, count.index) : null

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
