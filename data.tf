data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

// This is needed to circumvent:
// https://github.com/terraform-providers/terraform-provider-aws/issues/1352
data "aws_subnet" "subnets" {
  count = local.subnet_count

  id = element(local.subnet_ids, count.index)
}

data "aws_security_group" "default" {
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
