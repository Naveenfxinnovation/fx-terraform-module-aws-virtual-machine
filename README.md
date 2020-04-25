# Terraform module: Virtual Machine (EC2, AutoScaling Group)

Create X EC2/AutoScaling Group instances with X extra volumes, encrypted by default.

This module creates the same kind of instances.
They share the same features.
To create different instances, calls this module multiple times.

## Notes

To install pre-commit hooks: `pre-commit install`.
It will automatically `validate`, `fmt` and update *README.md* for you.

## Limitations

- AWS does not handle external volumes with AutoScaling Groups.
Because of this, if an AutoScaling Group with one or more EBS volume is destroy, the EBS volumes would be preserved, resulting in phantom volumes (unseen by Terraform).
That’s why every extra volumes within an AutoScaling group will always be destroyed by using this module (delete_on_termination = true).
- Same kind of resources will share the same tags. It’s not possible to assign tag to a specific instance, as specific volume or a specific network interface.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~>2.54 |
| null | ~>v2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>2.54 |
| null | ~>v2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | The AMI to use for the instances. | `string` | `""` | no |
| associate\_public\_ip\_address | Associate a public ip address for each instances. | `bool` | `false` | no |
| autoscaling\_group\_default\_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `null` | no |
| autoscaling\_group\_enabled\_metrics | A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances. | `set(string)` | `null` | no |
| autoscaling\_group\_health\_check\_grace\_period | Time (in seconds) after instance comes into service before checking health. | `number` | `null` | no |
| autoscaling\_group\_health\_check\_type | 'EC2' or 'ELB'. Controls how health checking is done. | `string` | `null` | no |
| autoscaling\_group\_max\_instance\_lifetime | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds. | `number` | `null` | no |
| autoscaling\_group\_max\_size | The maximum size of the auto scale group. | `number` | `1` | no |
| autoscaling\_group\_metrics\_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute. Default is 1Minute. | `string` | `null` | no |
| autoscaling\_group\_min\_elb\_capacity | Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. | `number` | `null` | no |
| autoscaling\_group\_min\_size | The minimum size of the auto scale group. | `number` | `1` | no |
| autoscaling\_group\_name | The name of the auto scaling group. By default generated by Terraform. | `string` | `null` | no |
| autoscaling\_group\_suspended\_processes | A list of processes to suspend for the AutoScaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly. | `set(string)` | `null` | no |
| autoscaling\_group\_tags | Tags specific to the AutoScaling Group. Will be merged with var.tags. | `map` | `{}` | no |
| autoscaling\_group\_target\_group\_arns | A list of aws\_alb\_target\_group ARNs, for use with Application or Network Load Balancing. | `list(string)` | `null` | no |
| autoscaling\_group\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default. | `list(string)` | `null` | no |
| autoscaling\_group\_wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `null` | no |
| autoscaling\_group\_wait\_for\_elb\_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over min\_elb\_capacity behavior.) | `number` | `null` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. | `bool` | `false` | no |
| ec2\_cpu\_core\_count | Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API. | `number` | `null` | no |
| ec2\_cpu\_credits | The credit option for CPU usage. Can be 'standard' or 'unlimited'. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default. | `string` | `null` | no |
| ec2\_cpu\_threads\_per\_core | (has no effect unless cpu\_core\_count is also set) If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See Optimizing CPU Options for more information. | `number` | `null` | no |
| ec2\_disable\_api\_termination | If true, enables EC2 Instance Termination Protection. | `bool` | `false` | no |
| ec2\_host\_id | The Id of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host. | `string` | `null` | no |
| ec2\_instance\_initiated\_shutdown\_behavior | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. | `string` | `null` | no |
| ec2\_ipv6\_address\_count | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. | `number` | `0` | no |
| ec2\_ipv6\_addresses | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface. | `list(string)` | `null` | no |
| ec2\_private\_ips | Private IPs of the instances. If set, the list must contain as many IP as the number of var.instance\_count. | `list(string)` | `null` | no |
| ec2\_source\_dest\_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| ec2\_tenancy | The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. | `string` | `"default"` | no |
| ec2\_volume\_tags | Tags of the root volume of the instance. Will be merged with tags. | `map` | `{}` | no |
| ephemeral\_block\_devices | Customize Ephemeral (also known as Instance Store) volumes on the instance. | `list(object({ device_name = string, virtual_name = string }))` | `[]` | no |
| external\_volume\_count | Number of external volumes to create. | `number` | `0` | no |
| external\_volume\_device\_names | Device names for the external volumes. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| external\_volume\_name | Prefix of the external volumes to create. | `string` | `"extra-volumes"` | no |
| external\_volume\_sizes | Size of the external volumes. | `list(number)` | <pre>[<br>  null<br>]</pre> | no |
| external\_volume\_tags | Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes. | `map` | `{}` | no |
| external\_volume\_types | The type of EBS volume. Can be 'standard', 'gp2', 'io1', 'sc1' or 'st1' (Default: 'gp2'). | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| extra\_network\_interface\_count | How many extra network interface to create per instance. This has no influence on the default network interface. | `number` | `0` | no |
| extra\_network\_interface\_private\_ips | List of private IPs to assign to the extra ENIs. Make sure you have as many element in the list as ENIs times the number of instances. | `list(list(string))` | <pre>[<br>  null<br>]</pre> | no |
| extra\_network\_interface\_private\_ips\_counts | Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private\_ips\_count, as a primary private IP will be assiged to an ENI by default. Make sure you have as many element in the list as ENIs times the number of instances. | `list(number)` | <pre>[<br>  null<br>]</pre> | no |
| extra\_network\_interface\_security\_group\_count | How many security groups to attach per extra ENI. This cannot be computed automatically from var.extra\_network\_interface\_security\_group\_ids in terraform 0.12. | `number` | `0` | no |
| extra\_network\_interface\_security\_group\_ids | List of security group IDs to assign to the extra ENIs. All ENIs will have the same security groups. | `list(list(string))` | `[]` | no |
| extra\_network\_interface\_source\_dest\_checks | Whether to enable source destination checking for the extra ENIs. Default true. | `list(bool)` | <pre>[<br>  null<br>]</pre> | no |
| extra\_network\_interface\_tags | Tags for the extra ENIs. Will be merged with tags. Tags will be shared among all extra ENIs. | `map` | `{}` | no |
| iam\_instance\_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| instance\_count | Number of instances to create. Can also be 0. | `number` | `1` | no |
| instance\_tags | Tags specific to the instances. | `map` | `{}` | no |
| instance\_type | The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance. | `string` | `"t3.small"` | no |
| key\_pair\_create | Whether or not to create a key pair. | `bool` | `false` | no |
| key\_pair\_name | The name for the key pair. If this is not null and key\_pair\_create = false, this name will be used as a key pair. | `string` | `null` | no |
| key\_pair\_public\_key | The public key material. | `string` | `null` | no |
| key\_pair\_tags | Tags for the key pair. Will be merged with tags. | `map` | `{}` | no |
| monitoring | If true, the launched EC2 instances will have detailed monitoring enabled. | `bool` | `false` | no |
| name | Name prefix of the instances. Will be suffixed by a var.num\_suffix\_digits count index. | `string` | `""` | no |
| num\_suffix\_digits | Number of significant digits to append to instances name. | `number` | `2` | no |
| placement\_group | The Placement Group to start the instances in. | `string` | `null` | no |
| root\_block\_device\_encrypted | Customize details about the root block device of the instance: Enables EBS encryption on the volume (Default: true). Cannot be used with snapshot\_id. Must be configured to perform drift detection. | `string` | `true` | no |
| root\_block\_device\_iops | Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2'). | `string` | `null` | no |
| root\_block\_device\_volume\_size | Customize details about the root block device of the instance: The size of the volume in gibibytes (GiB). | `string` | `null` | no |
| root\_block\_device\_volume\_type | Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2'). | `string` | `null` | no |
| subnet\_id | Subnet ID where to provision all the instances. Can be used instead or along with var.subnet\_ids. | `string` | `""` | no |
| subnet\_ids | Subnet IDs where to provision the instances. Can be used instead or along with var.subnet\_id. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| subnet\_ids\_count | How many subnet IDs in subnet\_ids. Cannot be computed automatically from other variables in Terraform 0.12.X. | `number` | `0` | no |
| tags | Tags to be used for all this module resources. Will be merged with specific tags. | `map` | `{}` | no |
| use\_autoscaling\_group | Weither or not to create an AutoScaling Group instead of EC2 instances. | `bool` | `false` | no |
| use\_num\_suffix | Always append numerical suffix to instance name, even if instance\_count is 1. | `bool` | `false` | no |
| user\_data | The user data to provide when launching the instance. | `string` | `null` | no |
| volume\_kms\_key\_alias | Alias of the KMS key used to encrypt the volumes. | `string` | `"alias/default/ec2"` | no |
| volume\_kms\_key\_arn | KMS key used to encrypt the volumes. To be used when var.volume\_kms\_key\_create is set to false. | `string` | `null` | no |
| volume\_kms\_key\_create | Whether or not to create a KMS key to be used for volumes encryption. | `bool` | `false` | no |
| volume\_kms\_key\_customer\_master\_key\_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports for the KMS key to be used for volumes. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. | `string` | `null` | no |
| volume\_kms\_key\_name | Name prefix for the KMS key to be used for volumes. Will be suffixes with a two-digit count index. | `string` | `null` | no |
| volume\_kms\_key\_policy | A valid policy JSON document for the KMS key to be used for volumes. | `string` | `null` | no |
| volume\_kms\_key\_tags | Tags for the KMS key to be used for volumes. Will be merge with var.tags. | `map` | `{}` | no |
| vpc\_security\_group\_ids | An object containing the list of security group IDs to associate with each instance. | `list(list(string))` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | n/a |
| autoscaling\_group\_id | n/a |
| availability\_zones | n/a |
| ec2\_arns | n/a |
| ec2\_ids | n/a |
| ec2\_primary\_network\_interface\_ids | n/a |
| ec2\_private\_dns | n/a |
| ec2\_private\_ips | n/a |
| ec2\_public\_dns | n/a |
| ec2\_public\_ips | n/a |
| external\_volume\_arns | n/a |
| external\_volume\_ids | n/a |
| extra\_network\_interface\_ids | n/a |
| extra\_network\_interface\_mac\_addresses | n/a |
| extra\_network\_interface\_private\_ips | n/a |
| key\_pair\_fingerprint | n/a |
| key\_pair\_id | n/a |
| key\_pair\_name | n/a |
| kms\_key\_id | n/a |
| launch\_configuration\_arn | n/a |
| launch\_configuration\_ebs\_block\_devices | n/a |
| launch\_configuration\_id | n/a |
| launch\_configuration\_name | n/a |
| subnet\_ids | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
