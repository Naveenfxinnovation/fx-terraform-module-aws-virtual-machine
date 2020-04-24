data "aws_vpc" "default" {
  count = local.use_default_subnets || var.vpc_security_group_ids == null ? 1 : 0

  default = true
}

data "aws_subnet_ids" "default" {
  count = local.use_default_subnets ? 1 : 0

  vpc_id = element(data.aws_vpc.default.*.id, 0)
}

// This is needed to circumvent:
// https://github.com/terraform-providers/terraform-provider-aws/issues/1352
data "aws_subnet" "subnets" {
  count = local.subnet_count

  id = element(local.subnet_ids, count.index)
}

data "aws_security_group" "default" {
  count = var.vpc_security_group_ids == null ? 1 : 0

  vpc_id = local.vpc_id
  name   = "default"
}

data "null_data_source" "ebs_block_device" {
  count = var.external_volume_count

  inputs = {
    device_name = element(var.external_volume_device_names, count.index)
    type        = element(var.external_volume_types, count.index)
    size        = element(var.external_volume_sizes, count.index)
  }
}
