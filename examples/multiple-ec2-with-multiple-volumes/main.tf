provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_vpc" "default" {
  default = true
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

resource "aws_security_group" "multiple_ec2_with_multiple_volumes" {
  name        = "tftest-standard_ec2_with_volume"
  description = "Terraform test standard_ec2_with_volume."
  vpc_id      = "${data.aws_vpc.default.id}"
}

module "multiple_ec2_with_multiple_volumes" {
  source = "../../"

  name = "tftest-multiple_ec2_with_multiple_volumes"

  ami                    = "${data.aws_ami.amazon_linux.image_id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.multiple_ec2_with_multiple_volumes.id}"]

  external_volume_kms_key_create = true

  volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  instance_count = 4

  external_volume_count        = 2
  external_volume_sizes        = [5, 10]
  external_volume_device_names = ["/dev/sdh", "/dev/sdi"]
}
