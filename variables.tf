####
# Global
####

variable "tags" {
  description = "Tags to be used for all this module resources. Will be merged with specific tags for each kind of resource."
  default     = {}
}

variable "use_autoscaling_group" {
  description = "Whether or not to create an AutoScaling Group instead of an EC2 instance. If `true`, use look at `autoscaling_group` prefixed variables."
  type        = bool
  default     = false
}

variable "use_num_suffix" {
  description = "Whether or not to append numerical suffix when multiple same resources need to be created like extra EBS volumes."
  type        = bool
  default     = true
}

variable "num_suffix_digits" {
  description = "Number of significant digits to append to multiple same resources of the module. For example, a `var.num_suffix_digits` of `3` would produce `-001`, `-002`… suffixes. Ignored if `var.use_num_suffix` is `false`."
  type        = number
  default     = 2

  validation {
    condition     = 1 <= var.num_suffix_digits && var.num_suffix_digits <= 10
    error_message = "The var.num_suffix_digits must be between 1 and 10."
  }
}

variable "num_suffix_offset" {
  description = "The starting point of the numerical suffix. An offset of 1 would mean resources suffixes will starts at 2. Ignored if `var.use_num_suffix` is `false`."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.num_suffix_offset && var.num_suffix_offset <= 9900
    error_message = "The var.num_suffix_offset must be between 0 and 9900."
  }
}

variable "prefix" {
  description = "Prefix to be added to with all resource's names of the module. Prefix is mainly used for tests and should remain empty in normal circumstances."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{0,16}$", var.prefix))
    error_message = "The var.prefix should match “^[a-z0-9-]{0,16}$”."
  }
}

####
# AutoScaling Group & EC2
####

variable "ami" {
  description = "AMI to use for the EC2 instance (or the launch template). Default: latest AWS linux AMI - CAREFUL: when using the default, the AMI ID could get updated, thus triggering a destroy/recreate of your instances. Besides testing, it's recommended to set a value."
  default     = null

  validation {
    condition     = var.ami == null || can(regex("^ami-([a-z0-9]{8}|[a-z0-9]{17})$", var.ami))
    error_message = "The var.ami must match “^ami-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "associate_public_ip_address" {
  description = "Whether or not to associate a public ip address for the EC2 instance (or launch template) main network interface."
  type        = bool
  default     = false
}

variable "cpu_credits" {
  description = "The credit option for CPU usage. Can be `standard` or `unlimited`. For T type instances. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default."
  type        = string
  default     = null

  validation {
    condition     = var.cpu_credits != null ? contains(["standard", "unlimited"], var.cpu_credits) : true
    error_message = "The var.cpu_credits must be “standard” or “unlimited”."
  }
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance (or launch template). This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "If set to to 1, hyperthreading is disabled on the launched instance (or launch template). Defaults to 2 if not set. See Optimizing CPU Options for more information (has no effect unless `var.cpu_core_count` is also set)."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_threads_per_core == null || var.cpu_threads_per_core == 1 || var.cpu_threads_per_core == 2
    error_message = "The var.cpu_threads_per_core must be “1” or “2”."
  }
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance (or launch template) will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it."
  type        = bool
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance (or launch template) termination protection. **This is NOT recommended** as it will prevent Terraform to destroy and block your pipeline."
  type        = bool
  default     = false
}

variable "ephemeral_block_devices" {
  description = <<-DOCUMENTATION
Customize Ephemeral (also known as Instance Store) volumes on the EC2 instance (or launch template):
  * device_name (required, string): The name of the block device to mount on the instance.
  * virtual_name (optional, string): The Instance Store Device Name (e.g. "ephemeral0").
  * no_device (optional, string): Suppresses the specified device included in the AMI's block device mapping.
DOCUMENTATION
  type        = list
  default     = []
}

variable "host_id" {
  description = "The Id of a dedicated host that the instance will be assigned to. Use when an instance (or launch template) is to be launched on a specific dedicated host."
  type        = string
  default     = null

  validation {
    condition     = var.host_id == null || can(regex("^h-([a-z0-9]{8}|[a-z0-9]{17})$", var.host_id))
    error_message = "The var.host_id must match “^h-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the EC2 instance (or launch template). Amazon defaults this to `stop` for EBS-backed instances and `terminate` for instance-store instances. Cannot be set on instance-store instances."
  type        = string
  default     = null

  validation {
    condition     = var.instance_initiated_shutdown_behavior == null || var.instance_initiated_shutdown_behavior == "stop" || var.instance_initiated_shutdown_behavior == "terminate"
    error_message = "The var.instance_initiated_shutdown_behavior must be “stop” or “terminate”."
  }
}

variable "instance_tags" {
  description = "Tags that will be shared with all the instances (or instances launched by the AutoScaling Group). Will be merged with `var.tags`."
  default     = {}
}

variable "instance_type" {
  description = "The type of instance (or launch template) to start. Updates to this field will trigger a stop/start of the EC2 instance, except with launch template."
  default     = "t3.nano"

  validation {
    condition     = can(regex("^(u-)?[a-z0-9]{2,4}\\.(nano|micro|small|medium|metal|(2|4|8|16|24)?x?large)$", var.instance_type))
    error_message = "The var.instance_type must match “^(u-)?[a-z0-9]{2,4}\\.(nano|micro|small|medium|metal|(2|4|8|16|24)?x?large)$”."
  }
}

variable "ipv4_address_count" {
  description = "A number of IPv4 addresses to associate with the primary network interface of the EC2 instance (or launch template). The total number of private IPs will be 1 + `var.ipv4_address_count`, as a primary private IP will be assigned to an ENI by default."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.ipv4_address_count && var.ipv4_address_count <= 50
    error_message = "The var.ipv4_address_count must be between 0 and 50."
  }
}

variable "monitoring" {
  description = "If `true`, the launched EC2 instance (or launch template) will have detailed monitoring enabled: 1 minute granularity instead of 5 minutes. Incurs additional costs."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name (tag:Name) of the instance(s) themselves, whether or not AutoScaling group is used."
  default     = "ec2"
}

variable "placement_group" {
  description = "ID of the Placement Group to start the EC2 instance (or launch template) in."
  type        = string
  default     = null

  validation {
    condition     = var.placement_group == null || can(regex("^pg-([a-z0-9]{8}|[a-z0-9]{17})$", var.placement_group))
    error_message = "The var.placement_group must match “^pg-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "primary_network_interface_name" {
  description = "Name (tag:Name) of the primary network interface to be attached to the EC2 instance (or launch template)."
  default     = "nic"
}

variable "root_block_device_delete_on_termination" {
  description = "Whether or not to delete the root block device on termination. **It's is strongly discouraged** to set this to `false`: only change this value if you have no other choice as this will leave a volume that will not be managed by terraform (even if the tag says it does) and you may end up building up costs."
  type        = bool
  default     = true
}

variable "root_block_device_volume_type" {
  description = "Customize details about the root block device of the instance or launch template root volume: The type of volume. Can be `standard`, `gp2`, `io1`, `sc1` or `st1`. (Default: `gp2`)."
  type        = string
  default     = null

  validation {
    condition     = var.root_block_device_volume_type != null ? contains(["standard", "gp2", "io1", "sc1", "st1"], var.root_block_device_volume_type) : true
    error_message = "The var.root_block_device_volume_type must be “standard”, “gp2”, “io1”, “sc1” or “st1”."
  }
}

variable "root_block_device_volume_device" {
  description = "Device name of the root volume of the AMI. Only used for Launch Template. This value cannot be found by the AWS Terraform provider from the AMI ID alone. If this value is wrong, Terraform will create an extra volume, failing to setup root volume correctly. Can be `/dev/sda1` or `/dev/xdva`."
  type        = string
  default     = "/dev/xvda"

  validation {
    condition     = contains(["/dev/xvda", "/dev/sda1"], var.root_block_device_volume_device)
    error_message = "The var.root_block_device_volume_device must be “/dev/xvda” or “/dev/sda1”."
  }
}

variable "root_block_device_volume_size" {
  description = "Customize details about the root block device of the instance or launch template root volume: The size of the volume in gibibytes (GiB)."
  type        = number
  default     = 8

  validation {
    condition     = var.root_block_device_volume_size == null || 1 <= tonumber(var.root_block_device_volume_size != null ? var.root_block_device_volume_size : 1) && tonumber(var.root_block_device_volume_size != null ? var.root_block_device_volume_size : 1) <= 20000
    error_message = "The var.root_block_device_volume_size must be between 1 and 20000."
  }
}

variable "root_block_device_iops" {
  description = "The amount of provisioned IOPS. This must be set when `var.root_block_device_volume_type` is `io1`."
  type        = number
  default     = null

  validation {
    condition     = var.root_block_device_iops == null || 10 <= tonumber(var.root_block_device_iops != null ? var.root_block_device_iops : 10) && tonumber(var.root_block_device_iops != null ? var.root_block_device_iops : 10) <= 64000
    error_message = "The var.root_block_device_iops must be between 10 and 64000."
  }
}

variable "root_block_device_encrypted" {
  description = "Customize details about the root block device of the EC2 instance (or launch template) root volume: enables EBS encryption on the volume. Cannot be used with snapshot_id. Must be configured to perform drift detection."
  type        = bool
  default     = true
}

variable "tenancy" {
  description = "The tenancy of the EC2 instance (if the instance or launch template will be running in a VPC). An instance with a tenancy of `dedicated` runs on single-tenant hardware. The `host` tenancy is not supported for the import-instance command."
  default     = null

  validation {
    condition     = var.tenancy == null || contains(["dedicated", "default", "host"], flatten([var.tenancy]))
    error_message = "The var.tenancy must be “dedicated”, “default” or “host”."
  }
}

variable "user_data" {
  description = "The user data to provide when launching the EC2 instance (or launch template)."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the main ENI of the EC2 instance (or launch template). If not defined, default the VPC security group will be used."
  type        = list(string)
  default     = null

  validation {
    condition     = var.vpc_security_group_ids != null ? ! contains([for i in var.vpc_security_group_ids : can(regex("^sg-([a-z0-9]{8}|[a-z0-9]{17})$", i))], false) : true
    error_message = "One or more of the “var.vpc_security_group_ids” does not match '^sg-([a-z0-9]{8}|[a-z0-9]{17})$'."
  }
}

####
# Launch Template
####

variable "launch_template_name" {
  description = "The name of the launch template. If you leave this blank, Terraform will auto-generate a unique name."
  type        = string
  default     = ""

  validation {
    condition     = var.launch_template_name == "" || (3 <= length(var.launch_template_name) && length(var.launch_template_name) <= 128 && can(regex("^[a-zA-Z0-9\\(\\)\\.\\-/_]+$", var.launch_template_name)))
    error_message = "The var.launch_template_name length must be between 3 and 128 characters and match “^[a-zA-Z0-9\\(\\)\\.\\-/_]+$”."
  }
}

variable "launch_template_tags" {
  description = "Tags to be used by the launch template. Will be merge with var.tags."
  default     = {}
}

variable "launch_template_ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface of the launch template."
  default     = 0

  validation {
    condition     = 0 <= var.launch_template_ipv6_address_count && var.launch_template_ipv6_address_count <= 50
    error_message = "The var.launch_template_ipv6_address_count must be between 0 and 50."
  }
}

####
# AutoScaling Group
####

variable "autoscaling_group_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = -1

  validation {
    condition     = -1 <= tonumber(var.autoscaling_group_default_cooldown) && var.autoscaling_group_default_cooldown <= 99999999
    error_message = "The var.autoscaling_group_default_cooldown must be between -1 (default) and 99999999."
  }
}

variable "autoscaling_group_enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity` and `GroupTotalInstances`."
  type        = set(string)
  default     = []

  validation {
    condition     = 0 == length(setsubtract(var.autoscaling_group_enabled_metrics, ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"]))
    error_message = "The var.autoscaling_group_enabled_metrics contains unsupported values (see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)."
  }
}

variable "autoscaling_group_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = -1

  validation {
    condition     = -1 <= tonumber(var.autoscaling_group_health_check_grace_period) && var.autoscaling_group_health_check_grace_period <= 99999999
    error_message = "The var.autoscaling_group_health_check_grace_period must be between -1 (default) and 99999999."
  }
}

variable "autoscaling_group_health_check_type" {
  description = "Controls how health checking is done on `EC2` level or on `ELB` level. When using a load balancer `ELB` is recommended."
  type        = string
  default     = null

  validation {
    condition     = var.autoscaling_group_health_check_type == null || var.autoscaling_group_health_check_type == "EC2" || var.autoscaling_group_health_check_type == "ELB"
    error_message = "The var.autoscaling_group_health_check_type must be “EC2” or “ELB”."
  }
}

variable "autoscaling_group_desired_capacity" {
  description = "Number of instances to immediately launch in the AutoScaling Group. If not specified, defaults to `var.autoscaling_group_min_size`."
  type        = number
  default     = null

  validation {
    condition     = var.autoscaling_group_desired_capacity != null ? 0 <= var.autoscaling_group_desired_capacity && var.autoscaling_group_desired_capacity <= 250 : true
    error_message = "The var.autoscaling_group_desired_capacity must be between 0 and 250."
  }
}

variable "autoscaling_group_max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to `0` or between `604800` and `31536000` seconds."
  type        = number
  default     = 0

  validation {
    condition     = var.autoscaling_group_max_instance_lifetime == 0 || (604800 <= var.autoscaling_group_max_instance_lifetime && var.autoscaling_group_max_instance_lifetime <= 31536000)
    error_message = "The var.autoscaling_group_max_instance_lifetime must be 0 or between 604800 and 31536000."
  }
}

variable "autoscaling_group_max_size" {
  description = "The maximum size of the AutoScaling Group."
  type        = number
  default     = 1

  validation {
    condition     = 1 <= var.autoscaling_group_max_size && var.autoscaling_group_max_size <= 250
    error_message = "The var.autoscaling_group_max_size must be between 1 and 250."
  }
}

variable "autoscaling_group_metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is `1Minute`. Default is `1Minute`."
  type        = string
  default     = null

  validation {
    condition     = var.autoscaling_group_metrics_granularity == null || var.autoscaling_group_metrics_granularity == "1Minute"
    error_message = "The var.autoscaling_group_metrics_granularity must be “1Minute”, it is the only supported value for now."
  }
}

variable "autoscaling_group_min_size" {
  description = "The minimum size of the AutoScaling Group."
  type        = number
  default     = 1

  validation {
    condition     = 0 <= var.autoscaling_group_min_size && var.autoscaling_group_min_size <= 250
    error_message = "The var.autoscaling_group_min_size must be between 0 and 250."
  }
}

variable "autoscaling_group_min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. [See documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#waiting-for-capacity)."
  type        = number
  default     = null
}

variable "autoscaling_group_name" {
  description = "The name of the AutoScaling Group. By default generated by Terraform."
  type        = string
  default     = ""

  validation {
    condition     = var.autoscaling_group_name == "" || (1 <= length(var.autoscaling_group_name) && length(var.autoscaling_group_name) <= 255 && can(regex("^[a-zA-Z0-9\\(\\)\\.\\-/_]+$", var.autoscaling_group_name)))
    error_message = "The var.autoscaling_group_name length must be between 1 and 255 characters and match “^[a-zA-Z0-9\\(\\)\\.\\-/_]+$”."
  }
}

variable "autoscaling_group_subnet_ids" {
  description = "IDs of the subnets to be used by the AutoScaling Group. If empty, all the default subnets of the current region will be used. This must have as many elements as the count: `var.autoscaling_group_subnet_ids_count`."
  type        = list(string)
  default     = [""]

  validation {
    condition     = length(compact(var.autoscaling_group_subnet_ids)) == 0 || ! contains([for i in var.autoscaling_group_subnet_ids : can(regex("^subnet-([a-z0-9]{8}|[a-z0-9]{17})$", i))], false)
    error_message = "One or more of the “var.autoscaling_group_subnet_ids” does not match “^subnet-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "autoscaling_group_subnet_ids_count" {
  description = "How many subnets IDs to be used by the AutoScaling Group in the `var.autoscaling_group_subnet_ids`. If the value is “0”, default subnets will be used. Cannot be computed automatically from other variables in Terraform 0.13.X."
  type        = number
  default     = 0

  validation {
    condition     = var.autoscaling_group_subnet_ids_count <= 6 && var.autoscaling_group_subnet_ids_count >= 0
    error_message = "The var.autoscaling_group_subnet_ids_count must be between 0 and 6."
  }
}

variable "autoscaling_group_suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly."
  type        = set(string)
  default     = []

  validation {
    condition     = 0 == length(setsubtract(var.autoscaling_group_suspended_processes, ["Launch", "Terminate", "HealthCheck", "ReplaceUnhealthy", "AZRebalance", "AlarmNotification", "ScheduledActions", "ScheduledActions", "AddToLoadBalancer"]))
    error_message = "The var.autoscaling_group_suspended_processes contains unsupported values (see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)."
  }
}

variable "autoscaling_group_target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing."
  type        = list(string)
  default     = []
}

variable "autoscaling_group_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`."
  type        = list(string)
  default     = []

  validation {
    condition     = 0 == length(setsubtract(var.autoscaling_group_termination_policies, ["OldestInstance", "NewestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour", "OldestLaunchTemplate", "AllocationStrategy", "Default"]))
    error_message = "The var.autoscaling_group_termination_policies contains unsupported values (see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)."
  }
}

variable "autoscaling_group_tags" {
  description = "Tags specific to the AutoScaling Group. Will be merged with var.tags."
  default     = {}
}

variable "autoscaling_group_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  default     = null

  validation {
    condition     = var.autoscaling_group_wait_for_capacity_timeout == null || can(regex("^[0-9]{0,3}m$", var.autoscaling_group_wait_for_capacity_timeout))
    error_message = "The var.autoscaling_group_wait_for_capacity_timeout match ”^[0-9]{0,3}m$“."
  }
}

variable "autoscaling_group_wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over `var.min_elb_capacity` behavior.)."
  type        = number
  default     = null
}

####
# AutoScaling Group Schedule
####

variable "autoscaling_schedule_count" {
  description = "How many AutoScaling Schedule actions to create on the AutoScaling Group. Ignored if `var.use_autoscaling_group` is `false`."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.autoscaling_schedule_count && var.autoscaling_schedule_count <= 125
    error_message = "The var.autoscaling_schedule_count must be between 0 and 125."
  }
}

variable "autoscaling_schedule_name" {
  description = "Name of the AutoScaling Schedule actions. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`. If `var.use_num_suffix` is `false` maximum one Schedule must be created as name must be unique. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = string
  default     = "asg-schedule"

  validation {
    condition     = 1 <= length(var.autoscaling_schedule_name) && length(var.autoscaling_schedule_name) <= 256
    error_message = "One or more var.autoscaling_schedule_name length must be between 1 and 256 characters."
  }
}

variable "autoscaling_schedule_min_sizes" {
  description = "The minimum sizes for the AutoScaling Schedule actions. Set to -1 if you don't want to change the minimum size at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(number)
  default     = [0]

  validation {
    condition     = ! contains([for i in var.autoscaling_schedule_min_sizes : (-1 <= i && i <= 250)], false)
    error_message = "One or more var.autoscaling_schedule_min_sizes aren't between -1 and 250."
  }
}

variable "autoscaling_schedule_max_sizes" {
  description = "The maximum sizes for the AutoScaling Schedule actions. Set to -1 if you don't want to change the maximum size at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(number)
  default     = [0]

  validation {
    condition     = ! contains([for i in var.autoscaling_schedule_max_sizes : (-1 <= i && i <= 250)], false)
    error_message = "One or more var.autoscaling_schedule_max_sizes aren't between -1 and 250."
  }
}

variable "autoscaling_schedule_desired_capacities" {
  description = "Number of instances that should run in the AutoScaling Schedule actions. Set to -1 if you don't want to change the desired capacity at the scheduled time. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(number)
  default     = [0]

  validation {
    condition     = ! contains([for i in var.autoscaling_schedule_desired_capacities : (-1 <= i && i <= 250)], false)
    error_message = "One or more var.autoscaling_schedule_desired_capacities aren't between -1 and 250."
  }
}

variable "autoscaling_schedule_recurrences" {
  description = "Times when recurring future AutoScaling Schedule actions will start. Start time is specified by the user following the Unix cron syntax format. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(string)
  default     = [null]

  validation {
    condition = var.autoscaling_schedule_recurrences[0] != null ? ! contains([for i in var.autoscaling_schedule_recurrences :
      can(regex(
        "^(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\\d+(ns|us|µs|ms|s|m|h))+)|((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})$",
    i))], false) : true
    error_message = "One or more var.autoscaling_schedule_recurrences doesn't match https://regexr.com/4jp54."
  }
}

variable "autoscaling_schedule_start_times" {
  description = "Time for the AutoScaling Schedule actions to start, in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, `2021-06-01T00:00:00Z` ). Defaults to the next minute. If you try to schedule your action in the past, Auto Scaling returns an error message. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(string)
  default     = [null]

  validation {
    condition     = var.autoscaling_schedule_start_times[0] != null ? ! contains([for i in var.autoscaling_schedule_start_times : can(regex("^\\d{4}-\\d{2}-\\d{2}T[0-2]\\d:[0-5]\\d:[0-5]\\dZ$", i))], false) : true
    error_message = "One or more var.autoscaling_schedule_start_times doesn't match “^\\d{4}-\\d{2}-\\d{2}T[0-2]\\d:[0-5]\\d:[0-5]\\dZ$”."
  }
}

variable "autoscaling_schedule_end_times" {
  description = "Time for the AutoScaling Schedule actions to stop, in `YYYY-MM-DDThh:mm:ssZ` format in UTC/GMT only (for example, `2022-06-01T00:00:00Z` ). If you try to schedule your action in the past, Auto Scaling returns an error message. Ignored if `var.use_autoscaling_group` or `var.autoscaling_schedule_enable` is `false`."
  type        = list(string)
  default     = [null]

  validation {
    condition     = var.autoscaling_schedule_end_times[0] != null ? ! contains([for i in var.autoscaling_schedule_end_times : can(regex("^\\d{4}-\\d{2}-\\d{2}T[0-2]\\d:[0-5]\\d:[0-5]\\dZ$", i))], false) : true
    error_message = "One or more var.autoscaling_schedule_end_times doesn't match “^\\d{4}-\\d{2}-\\d{2}T[0-2]\\d:[0-5]\\d:[0-5]\\dZ$”."
  }
}

####
# EC2
####

variable "ec2_ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface."
  type        = list(string)
  default     = []
}

variable "ec2_ipv4_addresses" {
  description = "Specify one or more IPv4 addresses from the range of the subnet to associate with the primary network interface."
  type        = list(string)
  default     = []

  validation {
    condition = ! contains([
      for i in var.ec2_ipv4_addresses : (
        can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", i))
      )
    ], false)
    error_message = "One or more of the var.ec2_ipv4_addresses does not match “^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$”."
  }
}

variable "ec2_source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  type        = bool
  default     = true
}

variable "ec2_subnet_id" {
  description = "Subnet ID where to provision all the instance. Can be used instead or along with var.subnet_ids."
  default     = null

  validation {
    condition     = var.ec2_subnet_id != null ? can(regex("^subnet-([a-z0-9]{8}|[a-z0-9]{17})$", var.ec2_subnet_id)) : true
    error_message = "The var.ec2_subnet_id must match “^subnet-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "ec2_use_default_subnet" {
  description = "Whether or not to use the VPC default subnet instead of `var.ec2_subnet_id`. Cannot be computed from `var.ec2_subnet_id` automatically in Terraform 0.13."
  type        = bool
  default     = true
}

variable "ec2_volume_name" {
  description = "Name (tag:Name) of the root block device of the instance."
  type        = string
  default     = "root-volume"

  validation {
    condition     = 1 <= length(var.ec2_volume_name) && length(var.ec2_volume_name) <= 128
    error_message = "The var.ec2_volume_name length must be between 1 and 128."
  }
}

variable "ec2_volume_tags" {
  description = "Tags of the root volume of the instance. Will be merged with `var.tags`."
  default     = {}
}

variable "ec2_primary_network_interface_create" {
  description = "Whether or not to create a primary Network Interface to be attached to EC2 instance. Ignored if `var.use_autoscaling_group` is `true`. If `false`, a value for `var.ec2_external_primary_network_interface_id` will be expected."
  type        = bool
  default     = true
}

variable "ec2_external_primary_network_interface_id" {
  description = "ID of the primary Network Interface to be attached to EC2 instance. This value must be given if `var.ec2_primary_network_interface_create` is `false`."
  type        = string
  default     = null

  validation {
    condition     = var.ec2_external_primary_network_interface_id != null ? can(regex("^eni-([a-z0-9]{8}|[a-z0-9]{17})$", var.ec2_external_primary_network_interface_id)) : true
    error_message = "The var.ec2_external_primary_network_interface_id must match “^eni-([a-z0-9]{8}|[a-z0-9]{17})$”."
  }
}

variable "ec2_network_interface_tags" {
  description = "Tags of the primary Network Interface of the EC2 instance. Will be merged with `var.tags`."
  default     = {}
}

####
# KMS
####

variable "volume_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt the root and extra volumes of the EC2 instance (or launch template). Do not prefix this value with `alias/` nor with a `/`."
  type        = string
  default     = "default/ec2"

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]{1,256}$", var.volume_kms_key_alias))
    error_message = "The var.volume_kms_key_alias must match “^[a-zA-Z0-9/_-]{1,256}$”."
  }
}

variable "volume_kms_key_arn" {
  description = "ARN of an external KMS key used to encrypt the root and extra volumes. To be used when `var.volume_kms_key_create` is set to `false` (if `true`, this ARN will be ignored). If this value is not null, also set `var.volume_kms_key_external_exist` to `true`."
  type        = string
  default     = null

  validation {
    condition     = var.volume_kms_key_arn == null || can(regex("^arn:aws:kms:([a-z]{2}-[a-z]{4,10}-[1-9]{1})?:[0-9]{12}:key/[a-z0-9-]{36}$", var.volume_kms_key_arn))
    error_message = "The var.volume_kms_key_arn must match “^arn:aws:kms:([a-z0-9-]{6,16})?:[0-9]{12}:key/[a-z0-9]{36}$”."
  }
}

variable "volume_kms_key_create" {
  description = "Whether or not to create a KMS key to be used for root and extra volumes. If set to `false`, you can specify a `var.volume_kms_key_arn` as an external KMS key to use instead. If this value is `false` and `var.volume_kms_key_arn` empty, the default AWS KMS key for volumes will be used."
  type        = bool
  default     = false
}

variable "volume_kms_key_external_exist" {
  description = "Whether or not `var.volume_kms_key_arn` is empty`. Cannot be computed automatically in Terraform 0.13."
  type        = bool
  default     = false
}

variable "volume_kms_key_customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports for the KMS key to be used for volumes. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`. Defaults to `SYMMETRIC_DEFAULT`."
  type        = string
  default     = null

  validation {
    condition     = var.volume_kms_key_customer_master_key_spec != null ? contains(["SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"], var.volume_kms_key_customer_master_key_spec) : true
    error_message = "The var.volume_kms_key_customer_master_key_spec must be one of 'SYMMETRIC_DEFAULT', 'RSA_2048', 'RSA_3072', 'RSA_4096', 'ECC_NIST_P256', 'ECC_NIST_P384', 'ECC_NIST_P384', 'ECC_NIST_P521' or 'ECC_SECG_P256K1'."
  }
}

variable "volume_kms_key_name" {
  description = "Name (tag:Name) for the KMS key to be used for root and extra volumes of the EC2 instance (or launch template)."
  type        = string
  default     = "kms-for-vol"

  validation {
    condition     = 1 <= length(var.volume_kms_key_name) && length(var.volume_kms_key_name) <= 128
    error_message = "The var.volume_kms_key_name length must be between 1 and 128."
  }
}

variable "volume_kms_key_policy" {
  description = "A valid policy JSON document for the KMS key to be used for root and extra volumes of the EC2 instance (or launch template). This document can give or restrict accesses for the key."
  type        = string
  default     = null

  validation {
    condition     = var.volume_kms_key_policy != null ? (can(jsondecode(var.volume_kms_key_policy)) && length(var.volume_kms_key_policy) < 131072) : true
    error_message = "The var.volume_kms_key_policy must be a valid JSON string that does not exceed 131072 characters."
  }
}

variable "volume_kms_key_tags" {
  description = "Tags for the KMS key to be used for root and extra volumes. Will be merge with `var.tags`."
  default     = {}
}

####
# Key Pair
####

variable "key_pair_create" {
  description = "Whether or not to create a key pair. If `false`, use `var.key_pair_name` to inject an external key pair."
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "The name for the key pair. If this is not empty and `var.key_pair_create` = `false`, this name will be used as an external key pair. If you don't want any key pair, set this to `null`."
  type        = string
  default     = null

  validation {
    condition     = var.key_pair_name == null || can(regex("^[ -~]{0,255}$", var.key_pair_name))
    error_message = "The var.key_pair_name must be between 1 and 255 ASCII characters."
  }
}

variable "key_pair_public_key" {
  description = "The public key material. Ignored if `var.key_pair_create` is `false`."
  type        = string
  default     = null

  validation {
    condition     = var.key_pair_public_key == null || can(regex("^^(ssh-rsa AAAAB3NzaC1yc2|ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNT|ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzOD|ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1Mj|ssh-ed25519 AAAAC3NzaC1lZDI1NTE5|ssh-dss AAAAB3NzaC1kc3)[0-9A-Za-z+/]+[=]{0,3}( .*)?$", var.key_pair_public_key))
    error_message = "The var.key_pair_public_key must be between a valid SSH public key."
  }
}

variable "key_pair_tags" {
  description = "Tags specific for the key pair. Will be merged with `var.tags`. Ignored if `var.key_pair_create` is `false`."
  default     = {}
}

####
# Instance Profile
####

variable "iam_instance_profile_create" {
  description = "Whether or not to create an Instance Profile (with its IAM Role) for the EC2 instance (or launch template). If `false`, you can use `var.iam_instance_profile_name` to use an external IAM Instance Profile."
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "The IAM profile's name for the EC2 instance (or launch template). If `var.iam_instance_profile_create` is `true` and this is null, Terraform will assign a random, unique name. If `var.iam_instance_profile_create` is `false` this value should be the name of an external IAM Instance Profile (keep it `null` to disable Instance Profile altogether)."
  type        = string
  default     = null

  validation {
    condition     = var.iam_instance_profile_name == null || can(regex("^[\\w+=,.@-]{1,128}$", var.iam_instance_profile_name))
    error_message = "The var.iam_instance_profile_name must match “^[\\w+=,.@-]{1,128}$”."
  }
}

variable "iam_instance_profile_path" {
  description = "Path in which to create the Instance Profile for the EC2 instance (or launch template). Instance Profile IAM Role will share the same path. Ignored if `var.iam_instance_profile_create` is `false`."
  default     = null

  validation {
    condition     = var.iam_instance_profile_path != null ? can(regex("^(\\x2F$)|(\\x2F[\\x21-\\x7F]+\\x2F)*$", var.iam_instance_profile_path)) : true
    error_message = "The var.iam_instance_profile_path must match “^(\\x2F$)|(\\x2F[\\x21-\\x7F]+\\x2F)*$”."
  }
}

variable "iam_instance_profile_iam_role_tags" {
  description = "Tags to be used for the Instance Profile Role. Will be merged with `var.tags`. Ignored if `var.iam_instance_profile_create` is `false`."
  default     = {}
}

variable "iam_instance_profile_iam_role_policy_arns" {
  description = "ARNs of the IAM Policies to be applied to the IAM Role of the Instance Profile. Ignored if `var.iam_instance_profile_create` is `false`."
  type        = list(string)
  default     = []

  validation {
    condition     = ! contains([for i in var.iam_instance_profile_iam_role_policy_arns : can(regex("^arn:aws:iam:([a-z]{2}-[a-z]{4,10}-[1-9]{1})?:([0-9]{12}|aws):policy/[a-zA-Z0-9+=,\\./@-]+$", i))], false)
    error_message = "One or more var.iam_instance_profile_iam_role_policy_arns don't match “^arn:aws:iam:([a-z]{2}-[a-z]{4,10}-[1-9]{1})?:([0-9]{12}|aws):policy/[a-zA-Z0-9+=,\\./@-]+$”."
  }
}

variable "iam_instance_profile_iam_role_policy_count" {
  description = "How many IAM Policy ARNs there are in `var.iam_instance_profile_iam_role_policy_arns`. This value cannot be computed automatically in Terraform 0.13."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.iam_instance_profile_iam_role_policy_count && var.iam_instance_profile_iam_role_policy_count <= 20
    error_message = "The var.iam_instance_profile_iam_role_policy_count must be between 0 and 20."
  }
}

variable "iam_instance_profile_iam_role_description" {
  description = "Description of the IAM Role to be used by the Instance Profile. Ignored if `var.iam_instance_profile_create` is `false`."
  type        = string
  default     = "Instance Profile Role"

  validation {
    condition     = can(regex("^[\\p{L}\\p{M}\\p{Z}\\p{S}\\p{N}\\p{P}]{0,1000}$", var.iam_instance_profile_iam_role_description))
    error_message = "The var.iam_instance_profile_iam_role_description must match “^[\\p{L}\\p{M}\\p{Z}\\p{S}\\p{N}\\p{P}]{0,1000}$”."
  }
}

variable "iam_instance_profile_iam_role_name" {
  description = "Name of the IAM Role to be used by the Instance Profile. If omitted, Terraform will assign a random, unique name. Ignored if `var.iam_instance_profile_create` is `false`."
  type        = string
  default     = null

  validation {
    condition     = var.iam_instance_profile_iam_role_name == null || can(regex("^[_+=,\\.@a-zA-Z0-9-]{1,128}$", var.iam_instance_profile_iam_role_name))
    error_message = "The var.iam_instance_profile_iam_role_name must match “^[_+=,\\.@a-zA-Z0-9-]{1,128}$”."
  }
}

####
# Elastic IP
####

variable "extra_network_interface_eips_count" {
  description = "How many extra Network Interfaces will have a public Elastic IP. Should be the exact number of `true`s in the `var.extra_network_interface_eips_enabled` list. Ignored if `var.use_autoscaling_group` is `true`."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.extra_network_interface_eips_count && var.extra_network_interface_eips_count <= 15
    error_message = "The var.extra_network_interface_eips_count must be between 0 and 15."
  }
}

variable "extra_network_interface_eips_enabled" {
  description = "List of boolean that indicates whether or not the extra Network Interface should have an Elastic IP or not. To disable/enable the EIP for specific NICs, use `false`/`true` respectively of the order of extra Network Interfaces. Should have as many `true`s as the number define in `var.extra_network_interface_eips_count`. Ignored if `var.use_autoscaling_group` is `true`."
  type        = list(bool)
  default     = []

  validation {
    condition     = 0 <= length(var.extra_network_interface_eips_enabled) && length(var.extra_network_interface_eips_enabled) <= 15
    error_message = "The var.extra_network_interface_eips_enabled length must be between 0 and 15."
  }
}

####
# Extra EBS
####

variable "extra_volume_count" {
  description = "Number of extra volumes to create for the EC2 instance (or the launch template)."
  default     = 0

  validation {
    condition     = var.extra_volume_count <= 11 && var.extra_volume_count >= 0
    error_message = "The var.extra_volume_count must be between 0 and 11."
  }
}

variable "extra_volume_device_names" {
  description = "Device names for the extra volumes to attached to the EC2 instance (or the launch template)."
  type        = list(string)
  default     = ["/dev/xvdf1"]

  validation {
    condition     = ! contains([for i in var.extra_volume_device_names : can(regex("^/dev/(sd|xvd|hd)[f-p][1-6]?$", i))], false)
    error_message = "One or more of the “var.extra_volume_device_names” does not match “^/dev/(sd|xvd)[f-p][1-6]?$”."
  }
}

variable "extra_volume_name" {
  description = "Name (tag:Name) of the extra volumes to create. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`. Otherwise, all the extra volumes will share the same name."
  type        = string
  default     = "vol"

  validation {
    condition     = 1 <= length(var.extra_volume_name) && length(var.extra_volume_name) <= 128
    error_message = "The var.extra_volume_name length must be between 0 and 128."
  }
}

variable "extra_volume_sizes" {
  description = "Size of the extra volumes for the EC2 instance (or launch template)."
  type        = list(number)
  default     = [1]
  validation {
    condition     = ! contains([for i in var.extra_volume_sizes : (i <= 16000 && i >= 1)], false)
    error_message = "One or more of the “var.extra_volume_sizes” is not between 1GB and 16TB."
  }
}

variable "extra_volume_tags" {
  description = "Tags shared by all the extra volumes of the instance or **all** the volumes of a launch template. Will be merged with `var.tags`."
  default     = {}
}

variable "extra_volume_types" {
  description = "The volume types of extra volumes to attach to the EC2 instance (or launch template). Can be `standard`, `gp2`, `io1`, `sc1` or `st1` (Default: `standard`)."
  type        = list(string)
  default     = ["gp2"]

  validation {
    condition     = ! contains([for i in var.extra_volume_types : (i == "standard" || i == "gp2" || i == "io1" || i == "sc1" || i == "st1")], false)
    error_message = "One or more of the “var.extra_volume_types” is not 'standard', 'gp2', 'io1', 'sc1' or 'st1'."
  }
}
####
# Network Interface
####

variable "extra_network_interface_count" {
  description = "How many extra network interface to create for the EC2 instance. This has no influence on the primary Network Interface. Ignored if `var.use_autoscaling_group` is `true`."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.extra_network_interface_count && var.extra_network_interface_count <= 15
    error_message = "The var.extra_network_interface_count must be between 0 and 15."
  }
}

variable "extra_network_interface_name" {
  description = "Name (tag:Name) of the extra Network Interfaces for the EC2 instance. Will be suffixed by numerical digits if `var.use_num_suffix` is `true`, otherwise all extra Network Interfaces will have the same name."
  default     = "nic"

  validation {
    condition     = 1 <= length(var.extra_network_interface_name) && length(var.extra_network_interface_name) <= 128
    error_message = "The var.extra_network_interface_name length must be between 0 and 128."
  }
}

variable "extra_network_interface_num_suffix_offset" {
  description = "The starting point of the numerical suffix for extra Network Interfaces for the EC2 instance. Will combine with `var.num_suffix_offset`. An offset of `1` here and `var.num_suffix_offset` of `2` would mean `var.extra_network_interface_name` suffix starts at `4`. Default value is `1` to let the primary Network Interface have the starting suffix."
  type        = number
  default     = 1

  validation {
    condition     = 0 <= var.extra_network_interface_num_suffix_offset && var.extra_network_interface_num_suffix_offset <= 9900
    error_message = "The var.extra_network_interface_num_suffix_offset must be between 0 and 9900."
  }
}

variable "extra_network_interface_private_ips" {
  description = "List of lists containing private IPs to assign to the extra Network Interfaces for the EC2 instance. Each list must correspond to an extra Network Interface, in order."
  type        = list(list(string))
  default     = [null]

  validation {
    condition = var.extra_network_interface_private_ips[0] != null ? ! contains([
      for i in flatten(var.extra_network_interface_private_ips) : (
        can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", i))
      )
    ], false) : true
    error_message = "One or more of the var.extra_network_interface_private_ips does not match “^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$”."
  }
}

variable "extra_network_interface_private_ips_counts" {
  description = "Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private_ips_count, as a primary private IP will be assigned to an ENI by default. Make sure you have as many element in the list as ENIs times the number of instances."
  type        = list(number)
  default     = [null]

  validation {
    condition = var.extra_network_interface_private_ips_counts[0] != null ? ! contains([
      for i in var.extra_network_interface_private_ips_counts : (0 <= i && i <= 50)
    ], false) : true
    error_message = "One or more of the var.extra_network_interface_private_ips_counts isn't between 0 and 50."
  }
}

variable "extra_network_interface_security_group_count" {
  description = "How many Security Groups to attach per extra Network Interface. Must be the number of element of `var.extra_network_interface_security_group_ids`. This cannot be computed automatically in Terraform 0.13."
  type        = number
  default     = 0

  validation {
    condition     = 0 <= var.extra_network_interface_security_group_count && var.extra_network_interface_security_group_count <= 16
    error_message = "The var.extra_network_interface_security_group_count must be between 0 and 16."
  }
}

variable "extra_network_interface_security_group_ids" {
  description = "List of Security Group IDs to assign to the extra Network Interfaces for the EC2 instance. All extra Network Interfaces will have the same Security Groups. If not specified, all ENI will have the `default` Security Group of the VPC."
  type        = list(string)
  default     = null

  validation {
    condition     = var.extra_network_interface_security_group_ids != null ? ! contains([for i in var.extra_network_interface_security_group_ids : can(regex("^sg-([a-z0-9]{8}|[a-z0-9]{17})$", i))], false) : true
    error_message = "One or more of the “var.extra_network_interface_security_group_ids” does not match '^sg-([a-z0-9]{8}|[a-z0-9]{17})$'."
  }
}

variable "extra_network_interface_source_dest_checks" {
  description = "Whether or not to enable source destination checking for the extra Network Interfaces for the EC2 instance. Default to `true`."
  type        = list(bool)
  default     = [null]
}

variable "extra_network_interface_tags" {
  description = "Tags for the extra Network Interfaces for the EC2 instance. Will be merged with `var.tags`. These tags will be shared among all extra ENIs."
  default     = {}
}
