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
