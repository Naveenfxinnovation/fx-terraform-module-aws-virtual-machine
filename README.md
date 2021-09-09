# Terraform module: Virtual Machine (EC2, AutoScaling Group)

This module have the following features, they are all optional:

- EC2 instance or one AutoScaling Group with X capacity.
- X extra volumes, encrypted by default, with optional KMS key.
- X extra network interfaces attached to the EC2 instance.
- A Key Pair.
- An Instance Profile.
- Elastic IPS for the instance and/or for specific extra network interfaces.

To create multiple instances, use `count`.

## Limitations

- AWS does not handle external volumes with AutoScaling Groups.
Because of this, if an AutoScaling Group with one or more EBS volume is destroy, the EBS volumes would be preserved, resulting in phantom volumes (unseen by Terraform).
That’s why every extra volumes within an AutoScaling group will always be destroyed by using this module (delete_on_termination = true).
- Same kind of resources will share the same tags. It’s not possible to assign tag to a specific EIP, as specific volume or a specific network interface.
- Since Terraform 0.13 and modules `count`, this module will not automatically balance instances in multiple subnets, except when using AutoScaling Group.
Also, the SSH Key Pair, KMS key and Instance Profile are not managed as before: if you use `count`, these resources will be created multiple times.
See examples to learn how to reuse them.

## Notes

To install pre-commit hooks: `pre-commit install`.
It will automatically `validate`, `fmt` and update *README.md* for you.

The variable `root_block_device_delete_on_termination` set to false is not tested because it will create resources that will persist a terraform build.
Therefore until we find a more permanent solution for this we do NOT test this feature.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_schedule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_ebs_volume.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.this_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.this_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_alias.this_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_grant.this_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_kms_key.this_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_network_interface.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.this_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_network_interface_sg_attachment.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_sg_attachment) | resource |
| [aws_volume_attachment.this_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_availability_zones.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.sts_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_ssm_parameter.default_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet_ids.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [null_data_source.ebs_block_device](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to use for the EC2 instance (or the launch template). Default: latest AWS linux AMI - CAREFUL: when using the default, the AMI ID could get updated, thus triggering a destroy/recreate of your instances. Besides testing, it's recommended to set a value. | `any` | `null` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether or not to associate a public ip address for the EC2 instance (or launch template) main network interface. | `bool` | `false` | no |
| <a name="input_autoscaling_group_default_cooldown"></a> [autoscaling\_group\_default\_cooldown](#input\_autoscaling\_group\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start. | `number` | `-1` | no |
| <a name="input_autoscaling_group_desired_capacity"></a> [autoscaling\_group\_desired\_capacity](#input\_autoscaling\_group\_desired\_capacity) | Number of instances to immediately launch in the AutoScaling Group. If not specified, defaults to `var.autoscaling_group_min_size`. | `number` | `null` | no |
| <a name="input_autoscaling_group_enabled_metrics"></a> [autoscaling\_group\_enabled\_metrics](#input\_autoscaling\_group\_enabled\_metrics) | A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity` and `GroupTotalInstances`. | `set(string)` | `[]` | no |
| <a name="input_autoscaling_group_health_check_grace_period"></a> [autoscaling\_group\_health\_check\_grace\_period](#input\_autoscaling\_group\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health. | `number` | `-1` | no |
| <a name="input_autoscaling_group_health_check_type"></a> [autoscaling\_group\_health\_check\_type](#input\_autoscaling\_group\_health\_check\_type) | Controls how health checking is done on `EC2` level or on `ELB` level. When using a load balancer `ELB` is recommended. | `string` | `null` | no |
| <a name="input_autoscaling_group_max_instance_lifetime"></a> [autoscaling\_group\_max\_instance\_lifetime](#input\_autoscaling\_group\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to `0` or between `604800` and `31536000` seconds. | `number` | `0` | no |
| <a name="input_autoscaling_group_max_size"></a> [autoscaling\_group\_max\_size](#input\_autoscaling\_group\_max\_size) | The maximum size of the AutoScaling Group. | `number` | `1` | no |
| <a name="input_autoscaling_group_metrics_granularity"></a> [autoscaling\_group\_metrics\_granularity](#input\_autoscaling\_group\_metrics\_granularity) | The granularity to associate with the metrics to collect. The only valid value is `1Minute`. Default is `1Minute`. | `string` | `null` | no |
| <a name="input_autoscaling_group_min_elb_capacity"></a> [autoscaling\_group\_min\_elb\_capacity](#input\_autoscaling\_group\_min\_elb\_capacity) | Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. [See documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#waiting-for-capacity). | `number` | `null` | no |
| <a name="input_autoscaling_group_min_size"></a> [autoscaling\_group\_min\_size](#input\_autoscaling\_group\_min\_size) | The minimum size of the AutoScaling Group. | `number` | `1` | no |
| <a name="input_autoscaling_group_name"></a> [autoscaling\_group\_name](#input\_autoscaling\_group\_name) | The name of the AutoScaling Group. By default generated by Terraform. | `string` | `""` | no |
| <a name="input_autoscaling_group_subnet_ids"></a> [autoscaling\_group\_subnet\_ids](#input\_autoscaling\_group\_subnet\_ids) | IDs of the subnets to be used by the AutoScaling Group. If empty, all the default subnets of the current region will be used. This must have as many elements as the count: `var.autoscaling_group_subnet_ids_count`. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_autoscaling_group_subnet_ids_count"></a> [autoscaling\_group\_subnet\_ids\_count](#input\_autoscaling\_group\_subnet\_ids\_count) | How many subnets IDs to be used by the AutoScaling Group in the `var.autoscaling_group_subnet_ids`. If the value is “0”, default subnets will be used. Cannot be computed automatically from other variables in Terraform 0.13.X. | `number` | `0` | no |
| <a name="input_autoscaling_group_suspended_processes"></a> [autoscaling\_group\_suspended\_processes](#input\_autoscaling\_group\_suspended\_processes) | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly. | `set(string)` | `[]` | no |
| <a name="input_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#input\_autoscaling\_group\_tags) | Tags specific to the AutoScaling Group. Will be merged with var.tags. | `map` | `{}` | no |
| <a name="input_autoscaling_group_target_group_arns"></a> [autoscaling\_group\_target\_group\_arns](#input\_autoscaling\_group\_target\_group\_arns) | A list of aws\_alb\_target\_group ARNs, for use with Application or Network Load Balancing. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_group_termination_policies"></a> [autoscaling\_group\_termination\_policies](#input\_autoscaling\_group\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_group_wait_for_capacity_timeout"></a> [autoscaling\_group\_wait\_for\_capacity\_timeout](#input\_autoscaling\_group\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `null` | no |
| <a name="input_autoscaling_group_wait_for_elb_capacity"></a> [autoscaling\_group\_wait\_for\_elb\_capacity](#input\_autoscaling\_group\_wait\_for\_elb\_capacity) | Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over `var.min_elb_capacity` behavior.). | `number` | `null` | no |
| <a name="input_autoscaling_schedule_count"></a> [autoscaling\_schedule\_count](#input\_autoscaling\_schedule\_count) | How many AutoScaling Schedule actions to create on the AutoScaling Group. Ignored if `var.use_autoscaling_group` is `false`. | `number` | `0` | no |
| <a name="input_autoscaling_schedule_desired_capacities"></a> [autoscaling\_schedule\_desired\_capacities](#input\_autoscaling\_schedule\_desired\_capacities) | Number of instances that should run in the AutoScaling Schedule actions. Set to -1 if you don't want to change the desired capacity at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(number)` | <pre>[<br>  0<br>]</pre> | no |
| <a name="input_autoscaling_schedule_end_times"></a> [autoscaling\_schedule\_end\_times](#input\_autoscaling\_schedule\_end\_times) | Time for the AutoScaling Schedule actions to stop, in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, `2022-06-01T00:00:00Z` ). If you try to schedule your action in the past, Auto Scaling returns an error message. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_autoscaling_schedule_max_sizes"></a> [autoscaling\_schedule\_max\_sizes](#input\_autoscaling\_schedule\_max\_sizes) | The maximum sizes for the AutoScaling Schedule actions. Set to -1 if you don't want to change the maximum size at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(number)` | <pre>[<br>  0<br>]</pre> | no |
| <a name="input_autoscaling_schedule_min_sizes"></a> [autoscaling\_schedule\_min\_sizes](#input\_autoscaling\_schedule\_min\_sizes) | The minimum sizes for the AutoScaling Schedule actions. Set to -1 if you don't want to change the minimum size at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(number)` | <pre>[<br>  0<br>]</pre> | no |
| <a name="input_autoscaling_schedule_name"></a> [autoscaling\_schedule\_name](#input\_autoscaling\_schedule\_name) | Name of the AutoScaling Schedule actions. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`. If `var.use_num_suffix` is `false` maximum one Schedule must be created as name must be unique. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `string` | `"asg-schedule"` | no |
| <a name="input_autoscaling_schedule_recurrences"></a> [autoscaling\_schedule\_recurrences](#input\_autoscaling\_schedule\_recurrences) | Times when recurring future AutoScaling Schedule actions will start. Start time is specified by the user following the Unix cron syntax format. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_autoscaling_schedule_start_times"></a> [autoscaling\_schedule\_start\_times](#input\_autoscaling\_schedule\_start\_times) | Time for the AutoScaling Schedule actions to start, in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, `2021-06-01T00:00:00Z` ). Defaults to the next minute. If you try to schedule your action in the past, Auto Scaling returns an error message. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_cpu_core_count"></a> [cpu\_core\_count](#input\_cpu\_core\_count) | Sets the number of CPU cores for an instance (or launch template). This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API. | `number` | `null` | no |
| <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits) | The credit option for CPU usage. Can be `standard` or `unlimited`. For T type instances. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default. | `string` | `null` | no |
| <a name="input_cpu_threads_per_core"></a> [cpu\_threads\_per\_core](#input\_cpu\_threads\_per\_core) | If set to to 1, hyperthreading is disabled on the launched instance (or launch template). Defaults to 2 if not set. See Optimizing CPU Options for more information (has no effect unless `var.cpu_core_count` is also set). | `number` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance (or launch template) termination protection. **This is NOT recommended** as it will prevent Terraform to destroy and block your pipeline. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance (or launch template) will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. | `bool` | `null` | no |
| <a name="input_ec2_external_primary_network_interface_id"></a> [ec2\_external\_primary\_network\_interface\_id](#input\_ec2\_external\_primary\_network\_interface\_id) | ID of the primary Network Interface to be attached to EC2 instance. This value must be given if `var.ec2_primary_network_interface_create` is `false`. | `string` | `null` | no |
| <a name="input_ec2_ipv4_addresses"></a> [ec2\_ipv4\_addresses](#input\_ec2\_ipv4\_addresses) | Specify one or more IPv4 addresses from the range of the subnet to associate with the primary network interface. | `list(string)` | `[]` | no |
| <a name="input_ec2_ipv6_addresses"></a> [ec2\_ipv6\_addresses](#input\_ec2\_ipv6\_addresses) | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface. | `list(string)` | `[]` | no |
| <a name="input_ec2_network_interface_tags"></a> [ec2\_network\_interface\_tags](#input\_ec2\_network\_interface\_tags) | Tags of the primary Network Interface of the EC2 instance. Will be merged with `var.tags`. | `map` | `{}` | no |
| <a name="input_ec2_primary_network_interface_create"></a> [ec2\_primary\_network\_interface\_create](#input\_ec2\_primary\_network\_interface\_create) | Whether or not to create a primary Network Interface to be attached to EC2 instance. Ignored if `var.use_autoscaling_group` is `true`. If `false`, a value for `var.ec2_external_primary_network_interface_id` will be expected. | `bool` | `true` | no |
| <a name="input_ec2_source_dest_check"></a> [ec2\_source\_dest\_check](#input\_ec2\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| <a name="input_ec2_subnet_id"></a> [ec2\_subnet\_id](#input\_ec2\_subnet\_id) | Subnet ID where to provision all the instance. Can be used instead or along with var.subnet\_ids. | `any` | `null` | no |
| <a name="input_ec2_use_default_subnet"></a> [ec2\_use\_default\_subnet](#input\_ec2\_use\_default\_subnet) | Whether or not to use the VPC default subnet instead of `var.ec2_subnet_id`. Cannot be computed from `var.ec2_subnet_id` automatically in Terraform 0.13. | `bool` | `true` | no |
| <a name="input_ec2_volume_name"></a> [ec2\_volume\_name](#input\_ec2\_volume\_name) | Name (tag:Name) of the root block device of the instance. | `string` | `"root-volume"` | no |
| <a name="input_ec2_volume_tags"></a> [ec2\_volume\_tags](#input\_ec2\_volume\_tags) | Tags of the root volume of the instance. Will be merged with `var.tags`. | `map` | `{}` | no |
| <a name="input_ephemeral_block_devices"></a> [ephemeral\_block\_devices](#input\_ephemeral\_block\_devices) | Customize Ephemeral (also known as Instance Store) volumes on the EC2 instance (or launch template):<br>  * device\_name (required, string): The name of the block device to mount on the instance.<br>  * virtual\_name (optional, string): The Instance Store Device Name (e.g. "ephemeral0").<br>  * no\_device (optional, string): Suppresses the specified device included in the AMI's block device mapping. | `list(any)` | `[]` | no |
| <a name="input_extra_network_interface_count"></a> [extra\_network\_interface\_count](#input\_extra\_network\_interface\_count) | How many extra network interface to create for the EC2 instance. This has no influence on the primary Network Interface. Ignored if `var.use_autoscaling_group` is `true`. | `number` | `0` | no |
| <a name="input_extra_network_interface_eips_count"></a> [extra\_network\_interface\_eips\_count](#input\_extra\_network\_interface\_eips\_count) | How many extra Network Interfaces will have a public Elastic IP. Should be the exact number of `true`s in the `var.extra_network_interface_eips_enabled` list. Ignored if `var.use_autoscaling_group` is `true`. | `number` | `0` | no |
| <a name="input_extra_network_interface_eips_enabled"></a> [extra\_network\_interface\_eips\_enabled](#input\_extra\_network\_interface\_eips\_enabled) | List of boolean that indicates whether or not the extra Network Interface should have an Elastic IP or not. To disable/enable the EIP for specific NICs, use `false`/`true` respectively of the order of extra Network Interfaces. Should have as many `true`s as the number define in `var.extra_network_interface_eips_count`. Ignored if `var.use_autoscaling_group` is `true`. | `list(bool)` | `[]` | no |
| <a name="input_extra_network_interface_name"></a> [extra\_network\_interface\_name](#input\_extra\_network\_interface\_name) | Name (tag:Name) of the extra Network Interfaces for the EC2 instance. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`, otherwise all extra Network Interfaces will have the same name. | `string` | `"nic"` | no |
| <a name="input_extra_network_interface_num_suffix_offset"></a> [extra\_network\_interface\_num\_suffix\_offset](#input\_extra\_network\_interface\_num\_suffix\_offset) | The starting point of the numerical suffix for extra Network Interfaces for the EC2 instance. Will combine with `var.num_suffix_offset`. An offset of `1` here and `var.num_suffix_offset` of `2` would mean `var.extra_network_interface_name` suffix starts at `4`. Default value is `1` to let the primary Network Interface have the starting suffix. | `number` | `1` | no |
| <a name="input_extra_network_interface_private_ips"></a> [extra\_network\_interface\_private\_ips](#input\_extra\_network\_interface\_private\_ips) | List of lists containing private IPs to assign to the extra Network Interfaces for the EC2 instance. Each list must correspond to an extra Network Interface, in order. | `list(list(string))` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_extra_network_interface_private_ips_counts"></a> [extra\_network\_interface\_private\_ips\_counts](#input\_extra\_network\_interface\_private\_ips\_counts) | Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private\_ips\_count, as a primary private IP will be assigned to an ENI by default. Make sure you have as many element in the list as ENIs times the number of instances. | `list(number)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_extra_network_interface_security_group_count"></a> [extra\_network\_interface\_security\_group\_count](#input\_extra\_network\_interface\_security\_group\_count) | How many Security Groups to attach per extra Network Interface. Must be the number of element of `var.extra_network_interface_security_group_ids`. This cannot be computed automatically in Terraform 0.13. | `number` | `0` | no |
| <a name="input_extra_network_interface_security_group_ids"></a> [extra\_network\_interface\_security\_group\_ids](#input\_extra\_network\_interface\_security\_group\_ids) | List of Security Group IDs to assign to the extra Network Interfaces for the EC2 instance. All extra Network Interfaces will have the same Security Groups. If not specified, all ENI will have the `default` Security Group of the VPC. | `list(string)` | `null` | no |
| <a name="input_extra_network_interface_source_dest_checks"></a> [extra\_network\_interface\_source\_dest\_checks](#input\_extra\_network\_interface\_source\_dest\_checks) | Whether or not to enable source destination checking for the extra Network Interfaces for the EC2 instance. Default to `true`. | `list(bool)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_extra_network_interface_tags"></a> [extra\_network\_interface\_tags](#input\_extra\_network\_interface\_tags) | Tags for the extra Network Interfaces for the EC2 instance. Will be merged with `var.tags`. These tags will be shared among all extra ENIs. | `map` | `{}` | no |
| <a name="input_extra_volume_count"></a> [extra\_volume\_count](#input\_extra\_volume\_count) | Number of extra volumes to create for the EC2 instance (or the launch template). | `number` | `0` | no |
| <a name="input_extra_volume_device_names"></a> [extra\_volume\_device\_names](#input\_extra\_volume\_device\_names) | Device names for the extra volumes to attached to the EC2 instance (or the launch template). | `list(string)` | <pre>[<br>  "/dev/xvdf1"<br>]</pre> | no |
| <a name="input_extra_volume_name"></a> [extra\_volume\_name](#input\_extra\_volume\_name) | Name (tag:Name) of the extra volumes to create. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`. Otherwise, all the extra volumes will share the same name. | `string` | `"vol"` | no |
| <a name="input_extra_volume_sizes"></a> [extra\_volume\_sizes](#input\_extra\_volume\_sizes) | Size of the extra volumes for the EC2 instance (or launch template). | `list(number)` | <pre>[<br>  1<br>]</pre> | no |
| <a name="input_extra_volume_tags"></a> [extra\_volume\_tags](#input\_extra\_volume\_tags) | Tags shared by all the extra volumes of the instance or **all** the volumes of a launch template. Will be merged with `var.tags`. | `map` | `{}` | no |
| <a name="input_extra_volume_types"></a> [extra\_volume\_types](#input\_extra\_volume\_types) | The volume types of extra volumes to attach to the EC2 instance (or launch template). Can be `standard`, `gp2`, `io1`, `sc1` or `st1` (Default: `standard`). | `list(string)` | <pre>[<br>  "gp2"<br>]</pre> | no |
| <a name="input_host_id"></a> [host\_id](#input\_host\_id) | The Id of a dedicated host that the instance will be assigned to. Use when an instance (or launch template) is to be launched on a specific dedicated host. | `string` | `null` | no |
| <a name="input_iam_instance_profile_create"></a> [iam\_instance\_profile\_create](#input\_iam\_instance\_profile\_create) | Whether or not to create an Instance Profile (with its IAM Role) for the EC2 instance (or launch template). If `false`, you can use `var.iam_instance_profile_name` to use an external IAM Instance Profile. | `bool` | `false` | no |
| <a name="input_iam_instance_profile_iam_role_description"></a> [iam\_instance\_profile\_iam\_role\_description](#input\_iam\_instance\_profile\_iam\_role\_description) | Description of the IAM Role to be used by the Instance Profile. Ignored if `var.iam_instance_profile_create` is `false`. | `string` | `"Instance Profile Role"` | no |
| <a name="input_iam_instance_profile_iam_role_name"></a> [iam\_instance\_profile\_iam\_role\_name](#input\_iam\_instance\_profile\_iam\_role\_name) | Name of the IAM Role to be used by the Instance Profile. If omitted, Terraform will assign a random, unique name. Ignored if `var.iam_instance_profile_create` is `false`. | `string` | `null` | no |
| <a name="input_iam_instance_profile_iam_role_policy_arns"></a> [iam\_instance\_profile\_iam\_role\_policy\_arns](#input\_iam\_instance\_profile\_iam\_role\_policy\_arns) | ARNs of the IAM Policies to be applied to the IAM Role of the Instance Profile. Ignored if `var.iam_instance_profile_create` is `false`. | `list(string)` | `[]` | no |
| <a name="input_iam_instance_profile_iam_role_policy_count"></a> [iam\_instance\_profile\_iam\_role\_policy\_count](#input\_iam\_instance\_profile\_iam\_role\_policy\_count) | How many IAM Policy ARNs there are in `var.iam_instance_profile_iam_role_policy_arns`. This value cannot be computed automatically in Terraform 0.13. | `number` | `0` | no |
| <a name="input_iam_instance_profile_iam_role_tags"></a> [iam\_instance\_profile\_iam\_role\_tags](#input\_iam\_instance\_profile\_iam\_role\_tags) | Tags to be used for the Instance Profile Role. Will be merged with `var.tags`. Ignored if `var.iam_instance_profile_create` is `false`. | `map` | `{}` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | The IAM profile's name for the EC2 instance (or launch template). If `var.iam_instance_profile_create` is `true` and this is null, Terraform will assign a random, unique name. If `var.iam_instance_profile_create` is `false` this value should be the name of an external IAM Instance Profile (keep it `null` to disable Instance Profile altogether). | `string` | `null` | no |
| <a name="input_iam_instance_profile_path"></a> [iam\_instance\_profile\_path](#input\_iam\_instance\_profile\_path) | Path in which to create the Instance Profile for the EC2 instance (or launch template). Instance Profile IAM Role will share the same path. Ignored if `var.iam_instance_profile_create` is `false`. | `any` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the EC2 instance (or launch template). Amazon defaults this to `stop` for EBS-backed instances and `terminate` for instance-store instances. Cannot be set on instance-store instances. | `string` | `null` | no |
| <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags) | Tags that will be shared with all the instances (or instances launched by the AutoScaling Group). Will be merged with `var.tags`. | `map` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance (or launch template) to start. Updates to this field will trigger a stop/start of the EC2 instance, except with launch template. | `string` | `"t3.nano"` | no |
| <a name="input_ipv4_address_count"></a> [ipv4\_address\_count](#input\_ipv4\_address\_count) | A number of IPv4 addresses to associate with the primary network interface of the EC2 instance (or launch template). The total number of private IPs will be 1 + `var.ipv4_address_count`, as a primary private IP will be assigned to an ENI by default. | `number` | `0` | no |
| <a name="input_key_pair_create"></a> [key\_pair\_create](#input\_key\_pair\_create) | Whether or not to create a key pair. If `false`, use `var.key_pair_name` to inject an external key pair. | `bool` | `false` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | The name for the key pair. If this is not empty and `var.key_pair_create` = `false`, this name will be used as an external key pair. If you don't want any key pair, set this to `null`. | `string` | `null` | no |
| <a name="input_key_pair_public_key"></a> [key\_pair\_public\_key](#input\_key\_pair\_public\_key) | The public key material. Ignored if `var.key_pair_create` is `false`. | `string` | `null` | no |
| <a name="input_key_pair_tags"></a> [key\_pair\_tags](#input\_key\_pair\_tags) | Tags specific for the key pair. Will be merged with `var.tags`. Ignored if `var.key_pair_create` is `false`. | `map` | `{}` | no |
| <a name="input_launch_template_ipv6_address_count"></a> [launch\_template\_ipv6\_address\_count](#input\_launch\_template\_ipv6\_address\_count) | A number of IPv6 addresses to associate with the primary network interface of the launch template. | `number` | `0` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | The name of the launch template. If you leave this blank, Terraform will auto-generate a unique name. | `string` | `""` | no |
| <a name="input_launch_template_tags"></a> [launch\_template\_tags](#input\_launch\_template\_tags) | Tags to be used by the launch template. Will be merge with var.tags. | `map` | `{}` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If `true`, the launched EC2 instance (or launch template) will have detailed monitoring enabled: 1 minute granularity instead of 5 minutes. Incurs additional costs. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (tag:Name) of the instance(s) themselves, whether or not AutoScaling group is used. | `string` | `"ec2"` | no |
| <a name="input_num_suffix_digits"></a> [num\_suffix\_digits](#input\_num\_suffix\_digits) | Number of significant digits to append to multiple same resources of the module. For example, a `var.num_suffix_digits` of `3` would produce `-001`, `-002`… suffixes. Ignored if `var.use_num_suffix` is `false`. | `number` | `2` | no |
| <a name="input_num_suffix_offset"></a> [num\_suffix\_offset](#input\_num\_suffix\_offset) | The starting point of the numerical suffix. An offset of 1 would mean resources suffixes will starts at 2. Ignored if `var.use_num_suffix` is `false`. | `number` | `0` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | ID of the Placement Group to start the EC2 instance (or launch template) in. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added to with all resource's names of the module. Prefix is mainly used for tests and should remain empty in normal circumstances. | `string` | `""` | no |
| <a name="input_primary_network_interface_name"></a> [primary\_network\_interface\_name](#input\_primary\_network\_interface\_name) | Name (tag:Name) of the primary network interface to be attached to the EC2 instance (or launch template). | `string` | `"nic"` | no |
| <a name="input_root_block_device_delete_on_termination"></a> [root\_block\_device\_delete\_on\_termination](#input\_root\_block\_device\_delete\_on\_termination) | Whether or not to delete the root block device on termination. **It's is strongly discouraged** to set this to `false`: only change this value if you have no other choice as this will leave a volume that will not be managed by terraform (even if the tag says it does) and you may end up building up costs. | `bool` | `true` | no |
| <a name="input_root_block_device_encrypted"></a> [root\_block\_device\_encrypted](#input\_root\_block\_device\_encrypted) | Customize details about the root block device of the EC2 instance (or launch template) root volume: enables EBS encryption on the volume. Cannot be used with snapshot\_id. Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_root_block_device_iops"></a> [root\_block\_device\_iops](#input\_root\_block\_device\_iops) | The amount of provisioned IOPS. This must be set when `var.root_block_device_volume_type` is `io1`. | `number` | `null` | no |
| <a name="input_root_block_device_volume_device"></a> [root\_block\_device\_volume\_device](#input\_root\_block\_device\_volume\_device) | Device name of the root volume of the AMI. Only used for Launch Template. This value cannot be found by the AWS Terraform provider from the AMI ID alone. If this value is wrong, Terraform will create an extra volume, failing to setup root volume correctly. Can be `/dev/sda1` or `/dev/xdva`. | `string` | `"/dev/xvda"` | no |
| <a name="input_root_block_device_volume_size"></a> [root\_block\_device\_volume\_size](#input\_root\_block\_device\_volume\_size) | Customize details about the root block device of the instance or launch template root volume: The size of the volume in gibibytes (GiB). | `number` | `8` | no |
| <a name="input_root_block_device_volume_type"></a> [root\_block\_device\_volume\_type](#input\_root\_block\_device\_volume\_type) | Customize details about the root block device of the instance or launch template root volume: The type of volume. Can be `standard`, `gp2`, `io1`, `sc1` or `st1`. (Default: `gp2`). | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be used for all this module resources. Will be merged with specific tags for each kind of resource. | `map` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the EC2 instance (if the instance or launch template will be running in a VPC). An instance with a tenancy of `dedicated` runs on single-tenant hardware. The `host` tenancy is not supported for the import-instance command. | `any` | `null` | no |
| <a name="input_use_autoscaling_group"></a> [use\_autoscaling\_group](#input\_use\_autoscaling\_group) | Whether or not to create an AutoScaling Group instead of an EC2 instance. If `true`, use look at `autoscaling_group` prefixed variables. | `bool` | `false` | no |
| <a name="input_use_num_suffix"></a> [use\_num\_suffix](#input\_use\_num\_suffix) | Whether or not to append numerical suffix when multiple same resources need to be created like extra EBS volumes. | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the EC2 instance (or launch template). | `string` | `null` | no |
| <a name="input_volume_kms_key_alias"></a> [volume\_kms\_key\_alias](#input\_volume\_kms\_key\_alias) | Alias of the KMS key used to encrypt the root and extra volumes of the EC2 instance (or launch template). Do not prefix this value with `alias/` nor with a `/`. | `string` | `"default/ec2"` | no |
| <a name="input_volume_kms_key_arn"></a> [volume\_kms\_key\_arn](#input\_volume\_kms\_key\_arn) | ARN of an external KMS key used to encrypt the root and extra volumes. To be used when `var.volume_kms_key_create` is set to `false` (if `true`, this ARN will be ignored). If this value is not null, also set `var.volume_kms_key_external_exist` to `true`. | `string` | `null` | no |
| <a name="input_volume_kms_key_create"></a> [volume\_kms\_key\_create](#input\_volume\_kms\_key\_create) | Whether or not to create a KMS key to be used for root and extra volumes. If set to `false`, you can specify a `var.volume_kms_key_arn` as an external KMS key to use instead. If this value is `false` and `var.volume_kms_key_arn` empty, the default AWS KMS key for volumes will be used. | `bool` | `false` | no |
| <a name="input_volume_kms_key_customer_master_key_spec"></a> [volume\_kms\_key\_customer\_master\_key\_spec](#input\_volume\_kms\_key\_customer\_master\_key\_spec) | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports for the KMS key to be used for volumes. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`. Defaults to `SYMMETRIC_DEFAULT`. | `string` | `null` | no |
| <a name="input_volume_kms_key_external_exist"></a> [volume\_kms\_key\_external\_exist](#input\_volume\_kms\_key\_external\_exist) | Whether or not `var.volume_kms_key_arn` is empty`. Cannot be computed automatically in Terraform 0.13.` | `bool` | `false` | no |
| <a name="input_volume_kms_key_name"></a> [volume\_kms\_key\_name](#input\_volume\_kms\_key\_name) | Name (tag:Name) for the KMS key to be used for root and extra volumes of the EC2 instance (or launch template). | `string` | `"kms-for-vol"` | no |
| <a name="input_volume_kms_key_policy"></a> [volume\_kms\_key\_policy](#input\_volume\_kms\_key\_policy) | A valid policy JSON document for the KMS key to be used for root and extra volumes of the EC2 instance (or launch template). This document can give or restrict accesses for the key. | `string` | `null` | no |
| <a name="input_volume_kms_key_tags"></a> [volume\_kms\_key\_tags](#input\_volume\_kms\_key\_tags) | Tags for the KMS key to be used for root and extra volumes. Will be merge with `var.tags`. | `map` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs to associate with the main ENI of the EC2 instance (or launch template). If not defined, default the VPC security group will be used. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | n/a |
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | n/a |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | n/a |
| <a name="output_ec2_arn"></a> [ec2\_arn](#output\_ec2\_arn) | n/a |
| <a name="output_ec2_id"></a> [ec2\_id](#output\_ec2\_id) | n/a |
| <a name="output_ec2_primary_network_interface_id"></a> [ec2\_primary\_network\_interface\_id](#output\_ec2\_primary\_network\_interface\_id) | n/a |
| <a name="output_ec2_private_dns"></a> [ec2\_private\_dns](#output\_ec2\_private\_dns) | n/a |
| <a name="output_ec2_private_ip"></a> [ec2\_private\_ip](#output\_ec2\_private\_ip) | n/a |
| <a name="output_ec2_public_dns"></a> [ec2\_public\_dns](#output\_ec2\_public\_dns) | n/a |
| <a name="output_ec2_public_ip"></a> [ec2\_public\_ip](#output\_ec2\_public\_ip) | n/a |
| <a name="output_eip_ids"></a> [eip\_ids](#output\_eip\_ids) | n/a |
| <a name="output_eip_network_interface_ids"></a> [eip\_network\_interface\_ids](#output\_eip\_network\_interface\_ids) | n/a |
| <a name="output_eip_public_dns"></a> [eip\_public\_dns](#output\_eip\_public\_dns) | n/a |
| <a name="output_eip_public_ips"></a> [eip\_public\_ips](#output\_eip\_public\_ips) | n/a |
| <a name="output_extra_volume_arns"></a> [extra\_volume\_arns](#output\_extra\_volume\_arns) | n/a |
| <a name="output_extra_volume_ids"></a> [extra\_volume\_ids](#output\_extra\_volume\_ids) | n/a |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | n/a |
| <a name="output_iam_instance_profile_iam_role_arn"></a> [iam\_instance\_profile\_iam\_role\_arn](#output\_iam\_instance\_profile\_iam\_role\_arn) | n/a |
| <a name="output_iam_instance_profile_iam_role_id"></a> [iam\_instance\_profile\_iam\_role\_id](#output\_iam\_instance\_profile\_iam\_role\_id) | n/a |
| <a name="output_iam_instance_profile_iam_role_unique_id"></a> [iam\_instance\_profile\_iam\_role\_unique\_id](#output\_iam\_instance\_profile\_iam\_role\_unique\_id) | n/a |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | n/a |
| <a name="output_iam_instance_profile_unique_id"></a> [iam\_instance\_profile\_unique\_id](#output\_iam\_instance\_profile\_unique\_id) | n/a |
| <a name="output_key_pair_fingerprint"></a> [key\_pair\_fingerprint](#output\_key\_pair\_fingerprint) | n/a |
| <a name="output_key_pair_id"></a> [key\_pair\_id](#output\_key\_pair\_id) | n/a |
| <a name="output_key_pair_name"></a> [key\_pair\_name](#output\_key\_pair\_name) | n/a |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | n/a |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | n/a |
| <a name="output_launch_template_default_version"></a> [launch\_template\_default\_version](#output\_launch\_template\_default\_version) | n/a |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | n/a |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | n/a |
| <a name="output_network_interface_eips"></a> [network\_interface\_eips](#output\_network\_interface\_eips) | n/a |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | n/a |
| <a name="output_network_interface_mac_addresses"></a> [network\_interface\_mac\_addresses](#output\_network\_interface\_mac\_addresses) | n/a |
| <a name="output_network_interface_private_dns_names"></a> [network\_interface\_private\_dns\_names](#output\_network\_interface\_private\_dns\_names) | n/a |
| <a name="output_network_interface_private_ips"></a> [network\_interface\_private\_ips](#output\_network\_interface\_private\_ips) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
