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
