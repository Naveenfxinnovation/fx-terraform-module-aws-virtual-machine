provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group" "standard_ec2_with_volume" {
  name        = "tftest-standard_ec2_with_volume"
  description = "Terraform test standard_ec2_with_volume."
  vpc_id      = "${data.aws_vpc.default.id}"
}

module "standard_ec2_with_volume" {
  source = "../../"

  name = "tftest-standard_ec2_with_volume"

  ami                    = "${data.aws_ami.amazon_linux.image_id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids = ["${aws_security_group.standard_ec2_with_volume.id}"]

  external_volume_size = 50
}
