data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  owners = ["137112412989"]

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
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

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

module "example" {
  source = "../../"

  name = "tftest-asg"

  subnet_ids_count = 2
  subnet_id        = data.aws_subnet_ids.all.ids
  ami              = data.aws_ami.amazon_linux.image_id
  instance_type    = "t3.micro"

  autoscaling_group_max_size          = 2
  autoscaling_group_min_size          = 1
  autoscaling_group_name              = "tftestasg${random_string.this.result}"
  health_check_type                   = "ELB"
  autoscaling_group_target_group_arns = [aws_lb_target_group.example.arn]
  autoscaling_group_tags = {
    Name = "tftestasg{random_string.this.result}"
  }
  autoscaling_group_wait_for_capacity_timeout = 15
  autoscaling_group_wait_for_elb_capacity     = 1

  autos = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_count = 2
  external_volume_sizes = [5]
}
