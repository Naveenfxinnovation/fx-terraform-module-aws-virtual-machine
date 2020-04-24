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

resource "aws_security_group" "example1" {
  name   = "tftest${random_string.this.result}1"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_key_pair" "example" {
  key_name   = "tftest${random_string.this.result}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAYu5mhM79nek7IsctWFXB8rkkmN2kmFBtNO8bVEsuxmB+WYBYwfpqWvzkSNtV3fTmnVKK+9zJtAxz7vke3DIg0e7asdQAC4TlyIQBye60dj5BT2AlAsjTjSoGZh9YQIAxvh7KBLBOiYBJ5VMQG0iQQwcpvZ1Lc1C81Uar1BE4ph5PRU9C7aukCtDW9j/L/BbxYWNLDdx/RvYKhRX87q7wDZztTYY0IJJzctysL67qV9V6dR9Ar2CGGxLAmKoMwBm60MILlC5UC/UPGCRVPULcrOpKphb72yujMS8R7QaPxqEvIXv0/bk0wa9b4azJoKNdp0L2St0M58WxXnNTlV0L dummy@key"
}

resource "aws_kms_key" "example" {
}

resource "aws_kms_alias" "example" {
  name          = "alias/tftest/${random_string.this.result}/ec2"
  target_key_id = aws_kms_key.example.key_id
}

data "aws_iam_policy_document" "example" {
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

resource "aws_iam_instance_profile" "example" {
  name = "tftest${random_string.this.result}"
  path = "/"
  role = aws_iam_role.example.id
}

resource "aws_iam_role" "example" {
  name               = "tftest${random_string.this.result}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.example.json
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "example" {
  source = "../../"

  name = "tftest-advanced_ec2_with_multiple_volumes"

  ami              = data.aws_ami.amazon_linux.image_id
  instance_type    = "m5a.large"
  subnet_ids_count = 2
  subnet_ids       = [element(sort(tolist(data.aws_subnet_ids.all.ids)), 0), element(sort(tolist(data.aws_subnet_ids.all.ids)), 1)]

  vpc_security_group_ids = [
    [aws_security_group.example1.id]
  ]

  use_num_suffix    = true
  num_suffix_digits = "03"

  user_data = "#!/bin/bash echo test"

  key_pair_create = false
  key_pair_name   = aws_key_pair.example.key_name

  ebs_optimized               = true
  monitoring                  = true
  associate_public_ip_address = true

  instance_tags = {
    Fullname = "Tftest instance."
  }

  ec2_source_dest_check = false
  ec2_volume_tags = {
    Name     = "tftest-advanced_ec2_with_multiple_volumes"
    Fullname = "Root volume for advanced_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name     = "tftest-advanced_ec2_with_multiple_volumes_external"
    Fullname = "External volumes for advanced_ec2_with_multiple_volumes"
  }

  volume_kms_key_create = false
  volume_kms_key_arn    = aws_kms_key.example.arn

  external_volume_count        = 3
  external_volume_sizes        = [500, 15]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi", "/dev/sdj"]
  external_volume_types        = ["sc1", "gp2"]

  extra_network_interface_count              = 1
  extra_network_interface_source_dest_checks = [true]
  extra_network_interface_tags = {
    NICName = "tftest${random_string.this.result}"
  }

  eip_create                           = true
  extra_network_interface_eips_count   = 1
  extra_network_interface_eips_enabled = [true]

  iam_instance_profile_arn = aws_iam_instance_profile.example.arn
}
