data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["ca-central-1a", "ca-central-1b"]
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

module "example" {
  source = "../../"

  name = "tftest-standard_ec2_with_volume"

  subnet_ids_count = 1
  subnet_id        = element(tolist(data.aws_subnet_ids.all.ids), 0)
  ami              = data.aws_ami.amazon_linux.image_id
  instance_type    = "t3.micro"

  ec2_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  external_volume_tags = {
    Name = "tftest-multiple_ec2_with_multiple_volumes"
  }

  volume_kms_key_create = true
  volume_kms_key_name   = "tftest${random_string.this.result}"
  volume_kms_key_alias  = "alias/tftest/${random_string.this.result}"

  external_volume_count        = 1
  external_volume_sizes        = [10]
  external_volume_device_names = ["/dev/sdh"]
}
