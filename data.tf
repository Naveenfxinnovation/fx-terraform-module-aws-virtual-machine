####
# Defaults
####

locals {
  should_fetch_default_subnet         = local.use_default_subnets
  should_fetch_default_security_group = var.vpc_security_group_ids == null
  should_fetch_default_vpc            = local.should_fetch_default_subnet || local.should_fetch_default_security_group
  should_fetch_default_ami            = var.ami == null
}

data "aws_availability_zones" "default" {
  count = local.should_fetch_default_subnet ? 1 : 0

  state = "available"
}

data "aws_vpc" "default" {
  count = local.should_fetch_default_vpc ? 1 : 0

  default = true
}

data "aws_subnets" "default" {
  count = local.should_fetch_default_subnet ? length(data.aws_availability_zones.default.*.names[0]) : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.*.id[0]]
  }
}

data "aws_security_group" "default" {
  count = local.should_fetch_default_security_group ? 1 : 0

  vpc_id = data.aws_vpc.default.*.id[0]
  name   = "default"
}

####
# Subnets
####

data "aws_subnet" "current" {
  count = length(local.subnet_ids)

  id = local.subnet_ids[count.index]
}

####
# EBS
####
#
locals {
  ebs_block_devices = [
    for i in range(var.extra_volume_count) : {
      device_name = element(var.extra_volume_device_names, i)
      type        = element(var.extra_volume_types, i)
      size        = element(var.extra_volume_sizes, i)
  }]
}

####
# IAM Instance Profile
####

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

####
# SSM Parameter
####

data "aws_ssm_parameter" "default_ami" {
  count = local.should_fetch_default_ami ? 1 : 0

  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
