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
