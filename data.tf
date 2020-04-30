####
# Defaults
####

data "aws_region" "current" {
  count = var.instance_count > 0 ? 1 : 0
}

data "aws_vpc" "default" {
  count = local.use_default_subnets ? 1 : 0

  default = true
}

data "aws_subnet_ids" "default" {
  count = local.use_default_subnets ? 1 : 0

  vpc_id = data.aws_vpc.default.*.id[0]

  filter {
    name   = "availability-zone"
    values = ["${element(concat(data.aws_region.current.*.name, [""]), 0)}a", "${element(concat(data.aws_region.current.*.name, [""]), 0)}b"]
  }
}

data "aws_security_group" "default" {
  count = var.instance_count > 0 && var.vpc_security_group_ids == null ? 1 : 0

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

data "aws_iam_policy_document" "sts_instance" {
  count = local.should_create_instance_profile ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}
