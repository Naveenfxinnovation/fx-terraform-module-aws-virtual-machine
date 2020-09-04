data "aws_vpc" "default" {
  default = true
}

resource "random_string" "this" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_subnet" "example" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = cidrsubnets(data.aws_vpc.default.cidr_block, 2, 8)[1]

}

data "aws_ssm_parameter" "linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-minimal-hvm-x86_64-ebs"
}

resource "aws_security_group" "example" {
  name   = "tftest${random_string.this.result}1"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "example2" {
  name   = "tftest${random_string.this.result}2"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_network_interface" "example" {
  count = 3

  subnet_id = aws_subnet.example.id
}

resource "aws_key_pair" "default" {
  key_name   = "tftest${random_string.this.result}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"
}

resource "aws_kms_key" "default" {
  description = "tftest${random_string.this.result}"
}

resource "aws_iam_instance_profile" "default" {}

#####
# EC2 with lots of options
# Shows how to:
# - use external subnets
# - use external security groups
# - pass an AMI
# - disable numerical suffixes for extras
# - assign 2 IPV4 addresses to primary network interface
# - choose instance type
# - change root block device options
# - disable root device encryption (not recommended)
# - use user data
# - create a key pair
# - create an instance profile with a role
# - enable monitoring
#####

module "options" {
  source = "../../"

  prefix         = format("%s-%s-", random_string.this.result, "opt")
  use_num_suffix = false

  instance_type = "t3.micro"
  ami           = data.aws_ssm_parameter.linux.value
  name          = "tftest"

  ec2_use_default_subnet = false
  ec2_subnet_id          = aws_subnet.example.id

  vpc_security_group_ids = [aws_security_group.example.id, aws_security_group.example2.id]

  ec2_ipv4_addresses          = [cidrhost(aws_subnet.example.cidr_block, 11), cidrhost(aws_subnet.example.cidr_block, 12)]
  associate_public_ip_address = false
  ebs_optimized               = true
  monitoring                  = true
  user_data                   = "#!/bin/bash\n\necho test"
  instance_tags = {
    Env = "test"
  }

  primary_network_interface_name = "tftest"
  ec2_network_interface_tags = {
    Env = "test"
  }

  key_pair_create     = true
  key_pair_name       = "tftest"
  key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohAK41 email@example.com"

  iam_instance_profile_create                = true
  iam_instance_profile_name                  = "tftest"
  iam_instance_profile_path                  = "/test/"
  iam_instance_profile_iam_role_policy_count = 1
  iam_instance_profile_iam_role_policy_arns  = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  iam_instance_profile_iam_role_description  = "Nice test IAM Role for instance profile"
  iam_instance_profile_iam_role_name         = "tftest"
  iam_instance_profile_iam_role_tags = {
    Env  = "test"
    Type = "options"
  }

  root_block_device_volume_size = 10
  root_block_device_encrypted   = false
  root_block_device_volume_type = "gp2"
  ec2_volume_tags = {
    Descrption = "Root volume of the EC2"
  }

  extra_volume_count        = 1
  extra_volume_sizes        = [1]
  extra_volume_name         = "tftest"
  extra_volume_device_names = ["/dev/sdh"]

  tags = {
    tftest = "options"
  }
}

#####
# EC2 with extra volumes
# Shows how to:
# - create simple instance with defaults
# - create a KMS key with alias for extra volumes
# - attach a couple extra volumes to the instance
#####

module "with_volumes" {
  source = "../../"

  prefix = format("%s-%s-", random_string.this.result, "vol")

  name = "tftest"

  ec2_volume_tags = {
    Name        = "tftest"
    Description = "Root volume"
  }

  volume_kms_key_create                   = true
  volume_kms_key_name                     = "tftest"
  volume_kms_key_alias                    = "tftest/test"
  volume_kms_key_customer_master_key_spec = "SYMMETRIC_DEFAULT"
  volume_kms_key_tags = {
    Description = "For extra volumes"
  }

  extra_volume_count        = 2
  extra_volume_sizes        = [1]
  extra_volume_name         = "tftest"
  extra_volume_device_names = ["/dev/sdh", "/dev/sdi"]
  extra_volume_types        = ["standard"]
  extra_volume_tags = {
    Name        = "tftest"
    External    = "true"
    Description = "Extra"
  }

  tags = {
    tftest = "volumes"
  }
}

#####
# EC2 with extra NICs & EIP
# Shows how to:
# - create simple instance with defaults
# - associate public IP with an EIP
# - use non-default instance type to have up to 3 NICs
# - attach a couple extra network interfaces with options (extra private IPS, suffix offset, SG)
# - attach an extra EIP to the second extra network interface only
#####

module "with_nic_and_eips" {
  source = "../../"

  prefix = format("%s-%s-", random_string.this.result, "nic")

  instance_type = "t3.small"

  name = "tftest"

  associate_public_ip_address = true

  extra_network_interface_num_suffix_offset    = 2
  extra_network_interface_count                = 2
  extra_network_interface_private_ips_counts   = [2, 1]
  extra_network_interface_security_group_count = 1
  extra_network_interface_security_group_ids   = [aws_security_group.example.id, aws_security_group.example2.id]
  extra_network_interface_source_dest_checks   = [true]
  extra_network_interface_tags = {
    NICName = "tftest"
  }

  extra_network_interface_eips_count   = 1
  extra_network_interface_eips_enabled = [false, true]

  tags = {
    tftest = "nic"
  }
}

#####
# EC2 with external resources
# Shows how to:
# - create three instances
# - use external subnets
# - use external security groups
# - pass an AMI
# - use external primary ENI
# - use external key pair
# - use external KMS key
# - create Instance Profile and reuse it on subsequent run
#####

module "externals" {
  source = "../../"

  count = 3

  prefix = format("%s-%s-", random_string.this.result, "ext")

  name = format("tftest-%02d", count.index)

  ami = data.aws_ssm_parameter.linux.value

  ec2_use_default_subnet = false
  ec2_subnet_id          = aws_subnet.example.id

  vpc_security_group_ids = [aws_security_group.example.id, aws_security_group.example2.id]

  ec2_primary_network_interface_create      = false
  ec2_external_primary_network_interface_id = aws_network_interface.example.*.id[count.index]
  key_pair_name                             = aws_key_pair.default.key_name
  volume_kms_key_arn                        = aws_kms_key.default.arn

  iam_instance_profile_create = count.index == 0 ? true : false
  // This is because of var.prefix. Real world usage shouldn't be that complex. This would do: iam_instance_profile_name = "tftest"
  iam_instance_profile_name = count.index == 0 ? "tftest" : format("%s-%s-%s", random_string.this.result, "ext", "tftest")
}
