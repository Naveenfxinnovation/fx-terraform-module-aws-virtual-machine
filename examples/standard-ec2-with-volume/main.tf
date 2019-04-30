//provider "aws" {
//  region     = "ca-central-1"
//  access_key = "${var.access_key}"
//  secret_key = "${var.secret_key}"
//}

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

  owners = ["137112412989"]

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

  subnet_id     = "${element(data.aws_subnet_ids.all.ids, 0)}"
  ami           = "${data.aws_ami.amazon_linux.image_id}"
  instance_type = "t2.micro"

  vpc_security_group_ids = {
    OK = "${aws_security_group.standard_ec2_with_volume.id}"
  }

  volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_kms_key_create = true
  external_volume_kms_key_alias  = "alias/tftest/ec2"

  external_volume_count        = 1
  external_volume_sizes        = [10]
  external_volume_device_names = ["/dev/sdh"]
}
