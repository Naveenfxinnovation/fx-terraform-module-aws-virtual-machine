#####
# Context
#####

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "aws_ssm_parameter" "default" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base"
}

resource "aws_key_pair" "default" {
  key_name   = "tftest${random_string.this.result}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"
}

resource "aws_kms_key" "default" {
  description = "tftest${random_string.this.result}"
}

resource "aws_security_group" "example" {
  name   = "tftest${random_string.this.result}1"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_iam_instance_profile" "default" {}

resource "random_string" "this" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_lb" "example" {
  name               = "tftestasg${random_string.this.result}"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnets.all.ids
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

#####
# ASG default
# Shows how to:
# - Create an ASG quickly without any option but defaults
# - Use default VPC/Subnets/Security Group
#####

module "default" {
  source = "../../"

  use_autoscaling_group = true

  prefix = format("%s-%s-", random_string.this.result, "dflt")
}

#####
# ASG empty
# Shows how to:
# - create an ASG without any instance
#####

module "empty" {
  source = "../../"

  use_autoscaling_group = true

  prefix = format("%s-%s-", random_string.this.result, "empt")

  autoscaling_group_min_size = 0
}

#####
# ASG Options
# Shows how to:
# - count with ASG
# - Use Windows AMI
# - Use explicit subnets
# - Use non-default security group
# - Use various ASG options
# - Use specific instance type
# - Create key pair on first run and reuse it on subsequent runs
# - Add extra volumes
# - Create KMS key for the volumes
# - Add an IAM Instance Profile/Role
# - Register ASG instances to a Target Group
# - Add ASG schedules to change capacity
#####

module "options" {
  source = "../../"

  count = 2

  prefix = format("%s-%s-", random_string.this.result, "opt")

  use_autoscaling_group = true
  name                  = "tftest-asg"
  launch_template_name  = format("%s-%02d", "tftest", count.index + 1)
  monitoring            = true

  ami                           = data.aws_ssm_parameter.default.value
  instance_type                 = "t3.medium"
  root_block_device_volume_size = 30

  tags = {
    Example = "TFTEST example"
  }

  instance_tags = {
    Name    = "tftest"
    Example = "TFTEST instance example"
  }

  vpc_security_group_ids = [aws_security_group.example.id]

  autoscaling_group_subnet_ids_count          = 2
  autoscaling_group_subnet_ids                = data.aws_subnets.all.ids
  autoscaling_group_name                      = format("%s-%02d", "tftestasg", count.index + 1)
  autoscaling_group_desired_capacity          = 1
  autoscaling_group_max_size                  = 2
  autoscaling_group_min_size                  = 1
  autoscaling_group_enabled_metrics           = ["GroupMinSize", "GroupMaxSize"]
  autoscaling_group_suspended_processes       = ["AlarmNotification"]
  autoscaling_group_health_check_type         = "ELB"
  autoscaling_group_target_group_arns         = [aws_lb_target_group.example.arn]
  autoscaling_group_wait_for_capacity_timeout = "15m"
  autoscaling_group_min_elb_capacity          = 1
  autoscaling_group_max_instance_lifetime     = 604800
  autoscaling_group_tags = {
    ASGName = "tftestasg"
  }

  key_pair_create = count.index == 0 ? true : false
  // This is because of prefix. Real world usage shouldn't be that complex: "tftest" would be sufficient.
  key_pair_name       = count.index == 0 ? "tftest" : format("%s-%s-%s", random_string.this.result, "opt", "tftest")
  key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"

  extra_volume_count        = 2
  extra_volume_sizes        = [1]
  extra_volume_device_names = ["/dev/sdh", "/dev/sdi"]

  volume_kms_key_name = format("%s%02d", "tftest", count.index)

  iam_instance_profile_iam_role_name         = "tftest${random_string.this.result}"
  iam_instance_profile_iam_role_policy_count = 1
  iam_instance_profile_iam_role_policy_arns  = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  autoscaling_schedule_name               = format("%s%s", "tftest${random_string.this.result}", count.index)
  autoscaling_schedule_count              = 2
  autoscaling_schedule_recurrences        = ["0 1 * * *", "0 8 * * *"]
  autoscaling_schedule_desired_capacities = [0, 1]
  autoscaling_schedule_start_times        = [timeadd(timestamp(), "30m"), timeadd(timestamp(), "35m")]
  autoscaling_schedule_max_sizes          = [0, 1]
}

#####
# ASG Externals
# Shows how to:
# - use default AMI with default subnet with default security group
# - use an external key pair
# - use an external IAM Instance Profile
# - use an external security group
# - use the module without an ELB
# - use /dev/sda1 root device name because of Windows AMI
#####

module "externals" {
  source = "../../"

  prefix = format("%s-%s-", random_string.this.result, "ext")

  use_autoscaling_group = true

  name = "tftest-asg-externals"

  tags = {
    Example = "TFTEST ASG externals"
  }

  launch_template_name = "tftest2"

  autoscaling_group_max_size          = 2
  autoscaling_group_min_size          = 1
  autoscaling_group_name              = "tftest-asg-externals"
  autoscaling_group_health_check_type = "EC2"

  root_block_device_volume_device = "/dev/sda1"

  vpc_security_group_ids        = [aws_security_group.example.id]
  key_pair_name                 = aws_key_pair.default.key_name
  volume_kms_key_external_exist = true
  volume_kms_key_arn            = aws_kms_key.default.arn
  iam_instance_profile_name     = aws_iam_instance_profile.default.name
}
