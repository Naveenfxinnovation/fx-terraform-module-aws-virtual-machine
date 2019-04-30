# Terraform module: EC2

Create X EC2 instances with X extra volumes, encrypted by default.

This module creates the same kind of instances.
They share the same features.
To create different instances, calls this module multiple times.

## Notes

To install pre-commit hooks: `pre-commit install`.
It will automatically `validate`, `fmt` and update *README.md* for you.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | The AMI to use for the instances. | string | `""` | no |
| associate\_public\_ip\_address | Associate a public ip address for each instances. | string | `"false"` | no |
| cpu\_credits | The credit option for CPU usage (unlimited or standard). | string | `"standard"` | no |
| disable\_api\_termination | If true, enables EC2 Instance Termination Protection. | string | `"false"` | no |
| ebs\_block\_device | Additional EBS block devices to attach to the instance. | list | `[]` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. | string | `"false"` | no |
| ephemeral\_block\_device | Customize Ephemeral (also known as Instance Store) volumes on the instance. | list | `[]` | no |
| external\_volume\_count | Number of external volumes to create. | string | `"0"` | no |
| external\_volume\_device\_names | Device names for the external volumes. | list | `[ "" ]` | no |
| external\_volume\_kms\_key\_alias | Alias of the KMS key used to encrypt the external volume. | string | `"alias/default/ec2"` | no |
| external\_volume\_kms\_key\_arn | KMS key used to encrypt the external volume. To be used | string | `""` | no |
| external\_volume\_kms\_key\_create | Whether or not to create KMS key. Cannot be computed from other variable in terraform 0.11.0. | string | `"true"` | no |
| external\_volume\_kms\_key\_name | Name prefix for the KMS key to be used for external volumes. Will be suffixes with a two-digit count index. | string | `""` | no |
| external\_volume\_kms\_key\_tags | Tags for the KMS key to be used for external volumes. | map | `{}` | no |
| external\_volume\_name | Prefix of the external volumes to create. | string | `"extra-volumes"` | no |
| external\_volume\_sizes | Size of the external volumes. | list | `[ "" ]` | no |
| external\_volume\_tags | Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes. | map | `{}` | no |
| iam\_instance\_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | string | `""` | no |
| instance\_count | Number of instances to create. Can also be 0. | string | `"1"` | no |
| instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. | string | `""` | no |
| instance\_tags | Tags specific to the instances. | map | `{}` | no |
| instance\_type | The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance. | string | `"t3.small"` | no |
| ipv6\_address\_count | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. | string | `"0"` | no |
| ipv6\_addresses | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface. | list | `[]` | no |
| key\_name | The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource. | string | `""` | no |
| monitoring | If true, the launched EC2 instances will have detailed monitoring enabled. | string | `"false"` | no |
| name | Name prefix of the instances. Will be suffixed by a var.num_suffix_digits count index. | string | `""` | no |
| num\_suffix\_digits | Number of significant digits to append to instances name. | string | `"2"` | no |
| placement\_group | The Placement Group to start the instances in. | string | `""` | no |
| private\_ips | Private IPs of the instances. If set, the list must contain as many IP as the number of var.instance_count. | list | `[]` | no |
| root\_block\_device | Customize details about the root block device of the instance. See Block Devices below for details | list | `[]` | no |
| source\_dest\_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | string | `"true"` | no |
| subnet\_id | Subnet ID where to provision all the instances. Can be used instead or along with var.subnet_ids. | string | `""` | no |
| subnet\_ids | Subnet IDs where to provision the instances. Can be used instead or along with var.subnet_id. | list | `[ "" ]` | no |
| subnet\_ids\_count | How many subnet IDs in subnet_ids. Cannot be computed automatically from other variables in Terraform 0.11.X. | string | `"0"` | no |
| tags | Tags to be used for all this module resources. Will be merged with specific tags. | map | `{}` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. | string | `"default"` | no |
| use\_num\_suffix | Always append numerical suffix to instance name, even if instance_count is 1. | string | `"false"` | no |
| user\_data | The user data to provide when launching the instance. | string | `""` | no |
| volume\_tags | Tags of the root volume of the instance. Will be merged with tags. | map | `{}` | no |
| vpc\_security\_group\_ids | An object containing the list of security group IDs to associate with each instance. | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arns | Instance ARNs. |
| availability\_zones | Availability zones of the instances. |
| credit\_specifications | Credit specification of instance. |
| external\_volume\_arns | ARNs of all the extra volumes. |
| external\_volume\_ids | IDs of all the extra volumes. |
| ids | Instance IDs. |
| kms\_key\_id | KMS key ID (ARN) used to encrypt all the extra volumes. |
| primary\_network\_interface\_ids | The IDs of the instances primary network interfaces. |
| private\_dns | Private domain names of the instances. |
| private\_ips | Private IPs of the instances. |
| public\_dns | Public domain names of the instances. |
| public\_ips | Public IPs of the instances. |
| subnet\_ids | The VPC subnet IDs where the instances are. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
