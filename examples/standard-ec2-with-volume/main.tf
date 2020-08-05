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

  prefix = random_string.this.result

  name = "tftest"

  ami           = data.aws_ami.amazon_linux.image_id
  instance_type = "t3.micro"

  ec2_volume_tags = {
    Name        = "tftest"
    Description = "Root volume"
  }

  external_volume_tags = {
    Name        = "tftest"
    External    = "true"
    Description = "External"
  }

  key_pair_create     = true
  key_pair_name       = "tftest"
  key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"

  volume_kms_key_create = true
  volume_kms_key_name   = "tftest"
  volume_kms_key_alias  = "tftest"

  external_volume_count        = 1
  external_volume_sizes        = [10]
  external_volume_device_names = ["/dev/sdh"]
}
