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
