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

resource "aws_lb" "example" {
  name               = "tftestasg${random_string.this.result}"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.all.ids
}

resource "aws_lb_target_group" "example" {
  name     = "tftestasg${random_string.this.result}"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.aws_vpc.default.id
}

module "example" {
  source = "../../"

  name = "tftest-asg"

  subnet_ids_count = 2
  subnet_ids       = data.aws_subnet_ids.all.ids
  ami              = data.aws_ami.windows_2019.image_id
  instance_type    = "t3.large"

  tags = {
    Example = "TFTEST example"
  }

  instance_tags = {
    Name    = "tftest${random_string.this.result}"
    Example = "TFTEST instance example"
  }

  use_autoscaling_group = true

  launch_template_name = "tftest${random_string.this.result}"

  autoscaling_group_max_size          = 2
  autoscaling_group_min_size          = 1
  autoscaling_group_name              = "tftestasg${random_string.this.result}"
  autoscaling_group_health_check_type = "ELB"
  autoscaling_group_target_group_arns = [aws_lb_target_group.example.arn]
  autoscaling_group_tags = {
    ASGName = "tftestasg${random_string.this.result}"
  }
  autoscaling_group_wait_for_capacity_timeout = "15m"
  autoscaling_group_wait_for_elb_capacity     = 1

  root_block_device_volume_size = 8
}
