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

  name = "tftest${random_string.this.result}"

  subnet_ids_count = 2
  subnet_ids       = data.aws_subnet_ids.all.ids
  ami              = data.aws_ami.amazon_linux.image_id
  instance_type    = "t3.micro"

  tags = {
    Example = "TFTEST example"
  }

  instance_tags = {
    Name    = "tftest${random_string.this.result}"
    Example = "TFTEST instance example"
  }

  use_autoscaling_group = true

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

  key_pair_create     = true
  key_pair_name       = "tftest${random_string.this.result}"
  key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"

  external_volume_count        = 2
  external_volume_sizes        = [5]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi"]

  iam_instance_profile_iam_role_name         = "tftest${random_string.this.result}"
  iam_instance_profile_iam_role_policy_count = 1
  iam_instance_profile_iam_role_policy_arns  = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}
