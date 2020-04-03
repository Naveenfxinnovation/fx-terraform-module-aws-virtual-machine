data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
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

resource "aws_security_group" "advanced_ec2_with_multiple_volumes" {
  name        = "tftest-advanced_ec2_with_multiple_volumes${random_string.this.result}"
  description = "Terraform test advanced_ec2_with_multiple_volumes."
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_key_pair" "advanced_ec2_with_multiple_volumes" {
  key_name   = "tftest_advanced_ec2_with_multiple_volumes"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAYu5mhM79nek7IsctWFXB8rkkmN2kmFBtNO8bVEsuxmB+WYBYwfpqWvzkSNtV3fTmnVKK+9zJtAxz7vke3DIg0e7asdQAC4TlyIQBye60dj5BT2AlAsjTjSoGZh9YQIAxvh7KBLBOiYBJ5VMQG0iQQwcpvZ1Lc1C81Uar1BE4ph5PRU9C7aukCtDW9j/L/BbxYWNLDdx/RvYKhRX87q7wDZztTYY0IJJzctysL67qV9V6dR9Ar2CGGxLAmKoMwBm60MILlC5UC/UPGCRVPULcrOpKphb72yujMS8R7QaPxqEvIXv0/bk0wa9b4azJoKNdp0L2St0M58WxXnNTlV0L dummy@key"
}

resource "aws_kms_key" "advanced_ec2_with_multiple_volumes" {
}

resource "aws_kms_alias" "advanced_ec2_with_multiple_volumes" {
  name          = "alias/tftest/advanced/ec2"
  target_key_id = aws_kms_key.advanced_ec2_with_multiple_volumes.key_id
}

module "advanced_ec2_with_multiple_volumes" {
  source = "../../"

  name = "tftest-advanced_ec2_with_multiple_volumes"

  ami              = data.aws_ami.amazon_linux.image_id
  instance_type    = "t3.micro"
  subnet_ids_count = 2
  subnet_ids       = [element(tolist(data.aws_subnet_ids.all.ids), 0), element(tolist(data.aws_subnet_ids.all.ids), 1)]

  vpc_security_group_ids = {
    "0" = aws_security_group.advanced_ec2_with_multiple_volumes.id
  }

  use_num_suffix    = true
  num_suffix_digits = "03"

  user_data = "#!/bin/bash echo test"
  key_name  = aws_key_pair.advanced_ec2_with_multiple_volumes.key_name

  ebs_optimized               = true
  monitoring                  = true
  associate_public_ip_address = true
  source_dest_check           = false

  instance_tags = {
    Fullname = "Tftest instance."
  }

  volume_tags = {
    Name     = "tftest-advanced_ec2_with_multiple_volumes"
    Fullname = "Root volume for advanced_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name     = "tftest-advanced_ec2_with_multiple_volumes_external"
    Fullname = "External volumes for advanced_ec2_with_multiple_volumes"
  }

  volume_kms_key_arn = aws_kms_key.advanced_ec2_with_multiple_volumes.arn

  external_volume_count        = 3
  external_volume_sizes        = [20, 10, 15]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi", "/dev/sdj"]
}

