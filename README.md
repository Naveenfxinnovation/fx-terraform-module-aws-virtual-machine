# Terraform module: Virtual Machine (EC2, AutoScaling Group)

Create X EC2/AutoScaling Group instances with X extra volumes, encrypted by default.

This module creates the same kind of instances.
They share the same features.
To create different instances, calls this module multiple times.

## Notes

To install pre-commit hooks: `pre-commit install`.
It will automatically `validate`, `fmt` and update *README.md* for you.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | ~>2.54.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ami | The AMI to use for the instances. | `string` | `""` | no |
| associate\_public\_ip\_address | Associate a public ip address for each instances. | `bool` | `false` | no |
| cpu\_core\_count | Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API. | `number` | n/a | yes |
| cpu\_credits | The credit option for CPU usage (unlimited or standard). | `string` | `"standard"` | no |
| cpu\_threads\_per\_core | (has no effect unless cpu\_core\_count is also set) If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See Optimizing CPU Options for more information. | `number` | n/a | yes |
| disable\_api\_termination | If true, enables EC2 Instance Termination Protection. | `bool` | `false` | no |
| ebs\_block\_devices | Additional EBS block devices to attach to the instance. | `list` | `[]` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. | `bool` | `false` | no |
| ephemeral\_block\_devices | Customize Ephemeral (also known as Instance Store) volumes on the instance. | `list(object({ device_name = string, virtual_name = string, no_device = string }))` | `[]` | no |
| external\_volume\_count | Number of external volumes to create. | `number` | `0` | no |
| external\_volume\_device\_names | Device names for the external volumes. | `list(string)` | <pre>[<br>  ""<br>]<br></pre> | no |
| external\_volume\_name | Prefix of the external volumes to create. | `string` | `"extra-volumes"` | no |
| external\_volume\_sizes | Size of the external volumes. | `list(number)` | `[]` | no |
| external\_volume\_tags | Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes. | `map` | `{}` | no |
| host\_id | The Id of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host. | `string` | n/a | yes |
| iam\_instance\_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| instance\_count | Number of instances to create. Can also be 0. | `number` | `1` | no |
| instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. | `string` | `""` | no |
| instance\_tags | Tags specific to the instances. | `map` | `{}` | no |
| instance\_type | The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance. | `string` | `"t3.small"` | no |
| ipv6\_address\_count | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. | `number` | `0` | no |
| ipv6\_addresses | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface. | `list(string)` | n/a | yes |
| key\_name | The key name of the Key Pair to use for the instance; which can be managed using the aws\_key\_pair resource. | `string` | `""` | no |
| monitoring | If true, the launched EC2 instances will have detailed monitoring enabled. | `bool` | `false` | no |
| name | Name prefix of the instances. Will be suffixed by a var.num\_suffix\_digits count index. | `string` | `""` | no |
| num\_suffix\_digits | Number of significant digits to append to instances name. Use a string containing a leading 0. | `string` | `"02"` | no |
| placement\_group | The Placement Group to start the instances in. | `string` | n/a | yes |
| private\_ips | Private IPs of the instances. If set, the list must contain as many IP as the number of var.instance\_count. | `list(string)` | n/a | yes |
| root\_block\_device\_encrypted | Customize details about the root block device of the instance: Enables EBS encryption on the volume (Default: true). Cannot be used with snapshot\_id. Must be configured to perform drift detection. | `string` | `true` | no |
| root\_block\_device\_iops | Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2'). | `string` | n/a | yes |
| root\_block\_device\_volume\_size | Customize details about the root block device of the instance: The size of the volume in gibibytes (GiB). | `string` | n/a | yes |
| root\_block\_device\_volume\_type | Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2'). | `string` | n/a | yes |
| source\_dest\_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| subnet\_id | Subnet ID where to provision all the instances. Can be used instead or along with var.subnet\_ids. | `string` | `""` | no |
| subnet\_ids | Subnet IDs where to provision the instances. Can be used instead or along with var.subnet\_id. | `list(string)` | <pre>[<br>  ""<br>]<br></pre> | no |
| subnet\_ids\_count | How many subnet IDs in subnet\_ids. Cannot be computed automatically from other variables in Terraform 0.11.X. | `number` | `0` | no |
| tags | Tags to be used for all this module resources. Will be merged with specific tags. | `map` | `{}` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. | `string` | `"default"` | no |
| use\_num\_suffix | Always append numerical suffix to instance name, even if instance\_count is 1. | `bool` | `false` | no |
| user\_data | The user data to provide when launching the instance. | `string` | n/a | yes |
| volume\_kms\_key\_alias | Alias of the KMS key used to encrypt the volumes. | `string` | `"alias/default/ec2"` | no |
| volume\_kms\_key\_arn | KMS key used to encrypt the volumes. To be used when var.volume\_kms\_key\_create is set to false. | `string` | n/a | yes |
| volume\_kms\_key\_create | Whether or not to create a KMS key to be used for volumes encryption. | `bool` | `true` | no |
| volume\_kms\_key\_customer\_master\_key\_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports for the KMS key to be used for volumes. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. | `string` | n/a | yes |
| volume\_kms\_key\_name | Name prefix for the KMS key to be used for volumes. Will be suffixes with a two-digit count index. | `string` | n/a | yes |
| volume\_kms\_key\_policy | A valid policy JSON document for the KMS key to be used for volumes. | `string` | n/a | yes |
| volume\_kms\_key\_tags | Tags for the KMS key to be used for volumes. Will be merge with var.tags. | `map` | `{}` | no |
| volume\_tags | Tags of the root volume of the instance. Will be merged with tags. | `map` | `{}` | no |
| vpc\_security\_group\_ids | An object containing the list of security group IDs to associate with each instance. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arns | n/a |
| availability\_zones | n/a |
| credit\_specifications | n/a |
| external\_volume\_arns | n/a |
| external\_volume\_ids | n/a |
| ids | n/a |
| kms\_key\_id | n/a |
| primary\_network\_interface\_ids | n/a |
| private\_dns | n/a |
| private\_ips | n/a |
| public\_dns | n/a |
| public\_ips | n/a |
| subnet\_ids | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
