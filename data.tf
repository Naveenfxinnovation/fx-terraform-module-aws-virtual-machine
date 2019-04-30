data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

// This is needed to circumvent:
// https://github.com/terraform-providers/terraform-provider-aws/issues/1352
data "aws_subnet" "instance_subnets" {
  count = "${element(var.subnet_ids, 0) != "" ? var.subnet_ids_count : length(data.aws_subnet_ids.all.ids)}"

  id = "${element(var.subnet_ids, 0) != "" ? element(var.subnet_ids, count.index) : element(data.aws_subnet_ids.all.ids, count.index)}"
}
