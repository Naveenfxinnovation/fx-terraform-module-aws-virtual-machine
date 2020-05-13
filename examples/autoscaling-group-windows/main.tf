data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  }
}

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_placement_group" "example" {
  name     = "tftest{random_string.this.result}"
  strategy = "cluster"
}

module "example" {
  source = "../../"

  name = "tftest-asg"

  subnet_ids_count = 2
  subnet_ids       = data.aws_subnet_ids.all.ids
  ami              = data.aws_ami.windows_2019.image_id
  instance_type    = "m5.large"

  tags = {
    Example = "TFTEST example"
  }

  instance_tags = {
    Name    = "tftest${random_string.this.result}"
    Example = "TFTEST instance example"
  }

  use_autoscaling_group = true

  launch_template_name = "tftest${random_string.this.result}"

  instance_count                      = 2
  autoscaling_group_max_size          = 2
  autoscaling_group_min_size          = 1
  autoscaling_group_name              = "tftestasg${random_string.this.result}"
  autoscaling_group_health_check_type = "EC2"
  autoscaling_group_tags = {
    ASGName = "tftestasg${random_string.this.result}"
  }
  autoscaling_group_wait_for_capacity_timeout = "15m"
  autoscaling_group_wait_for_elb_capacity     = 1

  // Does not work with Provider AWS 2.61: https://github.com/terraform-providers/terraform-provider-aws/issues/13236
  // Uncomment once Provider 2.62 is out
  //  placement_group = "tftest{random_string.this.result}"

  root_block_device_volume_size = 8
}
