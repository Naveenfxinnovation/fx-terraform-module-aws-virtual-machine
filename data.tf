####
# Defaults
####

data "aws_region" "current" {}

data "aws_vpc" "default" {
  count = local.use_default_subnets ? 1 : 0

  default = true
}

data "aws_subnet_ids" "default" {
  count = local.use_default_subnets ? 1 : 0

  vpc_id = data.aws_vpc.default.*.id[0]

  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  }
}

data "aws_security_group" "default" {
  count = var.vpc_security_group_ids == null ? 1 : 0

  vpc_id = local.vpc_id
  name   = "default"
}

####
# Subnets
####
// This is needed to circumvent:
// https://github.com/terraform-providers/terraform-provider-aws/issues/1352

data "aws_subnet" "subnets" {
  count = local.subnet_count

  id = element(local.subnet_ids, count.index)
}

####
# EBS
####

data "null_data_source" "ebs_block_device" {
  count = var.external_volume_count

  inputs = {
    device_name = element(var.external_volume_device_names, count.index)
    type        = element(var.external_volume_types, count.index)
    size        = element(var.external_volume_sizes, count.index)
  }
}
