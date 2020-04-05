data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"] # insert values here
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

module "multiple_ec2_with_multiple_volumes" {
  source = "../../"

  name = "tftest-multiple_ec2_with_multiple_volumes"

  ami                         = data.aws_ami.amazon_linux.image_id
  instance_type               = "t3.micro"
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

  ec2_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  // Reason for high number for instance count and external volumes is to
  // make sure the math is correct under the hood: 4 instances, 3 extra volumes, 2 subnets
  instance_count = 4

  external_volume_count        = 3
  external_volume_sizes        = [5, 6, 7]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi", "/dev/sdj"]
}
