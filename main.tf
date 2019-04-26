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

module "this" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.21.0"

  use_num_suffix = true

  name           = "${var.name}"
  instance_count = "${var.instance_count}"

  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  user_data              = "${var.user_data}"
  subnet_ids             = ["${data.aws_subnet.instance_subnets.*.id}"]
  key_name               = "${var.key_name}"
  monitoring             = "${var.monitoring}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  iam_instance_profile   = "${var.iam_instance_profile}"

  associate_public_ip_address = "${var.associate_public_ip_address}"
  private_ip                  = "${var.private_ip}"

  source_dest_check       = "${var.source_dest_check}"
  disable_api_termination = "${var.disable_api_termination}"

  ebs_optimized     = "${var.ebs_optimized}"
  volume_tags       = "${var.volume_tags}"
  ebs_block_device  = "${var.ebs_block_device}"
  root_block_device = "${var.root_block_device}"

  tags = "${merge(
    map("Terraform", "true"),
    var.tags
  )}"
}

resource "aws_volume_attachment" "this_ec2" {
  count = "${var.instance_count > 0 ? var.external_volume_count * var.instance_count : 0}"

  device_name = "${element(var.external_volume_device_names, count.index)}"
  volume_id   = "${element(aws_ebs_volume.this.*.id, count.index)}"
  instance_id = "${element(module.this.id, count.index % var.instance_count)}"
}

resource "aws_ebs_volume" "this" {
  count = "${var.instance_count > 0 ? var.external_volume_count * var.instance_count : 0}"

  availability_zone = "${element(data.aws_subnet.instance_subnets.*.availability_zone, count.index)}"
  size              = "${element(var.external_volume_sizes, floor(count.index / var.instance_count) % var.external_volume_count)}"

  encrypted  = true
  kms_key_id = "${element(coalescelist(list(var.external_volume_kms_key_arn), aws_kms_key.this.*.arn), 0)}"

  // Without https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/pull/85, we cannot have count suffixes
  tags = "${var.external_volume_tags}"
}

resource "aws_kms_key" "this" {
  count = "${var.instance_count > 0 && var.external_volume_kms_key_create ? 1 : 0}"

  description = "KMS key for ${var.name} external volume."

  tags = "${merge(
    map("Name", format("%s-%02d", var.external_volume_kms_key_name, count.index + 1)),
    map("Terraform", "true"),
    var.tags,
    var.external_volume_kms_key_tags
  )}"
}
