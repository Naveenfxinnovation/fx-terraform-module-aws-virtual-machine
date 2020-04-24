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

resource "aws_security_group" "example2" {
  name   = "tftest${random_string.this.result}2"
  vpc_id = data.aws_vpc.default.id
}

module "example" {
  source = "../../"

  name = "tftest-multiple_ec2_with_multiple_volumes"

  ami                         = data.aws_ami.amazon_linux.image_id
  instance_type               = "m5a.large"
  root_block_device_encrypted = true

  subnet_ids_count = 2
  subnet_ids       = [element(tolist(data.aws_subnet_ids.all.ids), 0), element(tolist(data.aws_subnet_ids.all.ids), 1)]

  vpc_security_group_ids = [
    [aws_security_group.example1.id, aws_security_group.example2.id],
    [aws_security_group.example1.id],
    [aws_security_group.example1.id],
    [aws_security_group.example1.id],
  ]

  volume_kms_key_create = true
  volume_kms_key_name   = "tftest${random_string.this.result}"
  volume_kms_key_alias  = "alias/tftest/${random_string.this.result}"

  ec2_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  // Reason for high number for instance count and external volumes is to
  // make sure the math is correct under the hood: 4 instances, 3 extra volumes, 2 subnets, 2 extra NICs
  instance_count = 4

  external_volume_count        = 3
  external_volume_sizes        = [5, 6, 7]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi", "/dev/sdj"]

  extra_network_interface_count                = 2
  extra_network_interface_private_ips_counts   = [2, 1]
  extra_network_interface_security_group_count = 1
  extra_network_interface_security_group_ids   = [[aws_security_group.example2.id]]
  extra_network_interface_source_dest_checks   = [true]
  extra_network_interface_tags = {
    NICName = "tftest${random_string.this.result}"
  }

  iam_instance_profile_create = false
}
