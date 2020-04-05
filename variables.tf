####
# Global
####

variable "tags" {
  description = "Tags to be used for all this module resources. Will be merged with specific tags."
  default     = {}
}

variable "use_autoscaling_group" {
  description = "Weither or not to create an AutoScaling Group instead of EC2 instances."
  type        = bool
  default     = false
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1."
  default     = false
}

####
# AutoScaling Group & EC2
####

variable "ami" {
  description = "The AMI to use for the instances."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address for each instances."
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it."
  default     = false
}

variable "ephemeral_block_devices" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance."
  type        = list(object({ device_name = string, virtual_name = string }))
  default     = []
}

variable "instance_count" {
  description = "Number of instances to create. Can also be 0."
  default     = 1
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "instance_tags" {
  description = "Tags specific to the instances."
  default     = {}
}

variable "instance_type" {
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
  default     = "t3.small"
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource."
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instances will have detailed monitoring enabled."
  default     = false
}

variable "name" {
  description = "Name prefix of the instances. Will be suffixed by a var.num_suffix_digits count index."
  default     = ""
}

variable "num_suffix_digits" {
  description = "Number of significant digits to append to instances name."
  type        = number
  default     = 2
}

variable "placement_group" {
  description = "The Placement Group to start the instances in."
  type        = string
  default     = null
}

variable "root_block_device_volume_type" {
  description = "Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2')."
  type        = string
  default     = null
}

variable "root_block_device_volume_size" {
  description = "Customize details about the root block device of the instance: The size of the volume in gibibytes (GiB)."
  type        = string
  default     = null
}

variable "root_block_device_iops" {
  description = "Customize details about the root block device of the instance: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2')."
  type        = string
  default     = null
}

variable "root_block_device_encrypted" {
  description = "Customize details about the root block device of the instance: Enables EBS encryption on the volume (Default: true). Cannot be used with snapshot_id. Must be configured to perform drift detection."
  type        = string
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID where to provision all the instances. Can be used instead or along with var.subnet_ids."
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs where to provision the instances. Can be used instead or along with var.subnet_id."
  type        = list(string)
  default     = [""]
}

variable "subnet_ids_count" {
  description = "How many subnet IDs in subnet_ids. Cannot be computed automatically from other variables in Terraform 0.11.X."
  default     = 0
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "An object containing the list of security group IDs to associate with each instance."
  type        = list(list(string))
  default     = null
}

####
# AutoScaling Group
####

variable "autoscaling_group_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = null
}

variable "autoscaling_group_enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = string
  default     = null
}

variable "autoscaling_group_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = null
}

variable "autoscaling_group_health_check_type" {
  description = "'EC2' or 'ELB'. Controls how health checking is done."
  type        = string
  default     = null
}

variable "autoscaling_group_max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds."
  type        = number
  default     = null
}

variable "autoscaling_group_max_size" {
  description = "The maximum size of the auto scale group."
  type        = number
  default     = 1
}

variable "autoscaling_group_metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute. Default is 1Minute."
  type        = string
  default     = null
}

variable "autoscaling_group_min_size" {
  description = "The minimum size of the auto scale group."
  type        = number
  default     = 1
}

variable "autoscaling_group_min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes."
  type        = number
  default     = null
}

variable "autoscaling_group_name" {
  description = "The name of the auto scaling group. By default generated by Terraform."
  type        = string
  default     = null
}

variable "autoscaling_group_suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly."
  type        = string
  default     = null
}

variable "autoscaling_group_target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing."
  type        = list(string)
  default     = null
}

variable "autoscaling_group_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = string
  default     = null
}

variable "autoscaling_group_tags" {
  description = "Tags specific to the AutoScaling Group. Will be merged with var.tags."
  default     = {}
}

variable "autoscaling_group_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = number
  default     = null
}

variable "autoscaling_group_wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. (Takes precedence over min_elb_capacity behavior.)"
  type        = number
  default     = null
}

####
# EC2
####

variable "ec2_cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)."
  default     = "standard"
}

variable "ec2_cpu_core_count" {
  description = "Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API."
  type        = number
  default     = null
}

variable "ec2_cpu_threads_per_core" {
  description = "(has no effect unless cpu_core_count is also set) If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See Optimizing CPU Options for more information."
  type        = number
  default     = null
}

variable "ec2_disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  default     = false
}

variable "ec2_host_id" {
  description = "The Id of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host."
  type        = string
  default     = null
}

variable "ec2_instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances."
  default     = ""
}

variable "ec2_ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface."
  type        = list(string)
  default     = null
}

variable "ec2_ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "ec2_private_ips" {
  description = "Private IPs of the instances. If set, the list must contain as many IP as the number of var.instance_count."
  type        = list(string)
  default     = null
}

variable "ec2_source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "ec2_tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command."
  default     = "default"
}

variable "ec2_volume_tags" {
  description = "Tags of the root volume of the instance. Will be merged with tags."
  default     = {}
}

####
# KMS
####

variable "volume_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt the volumes."
  type        = string
  default     = "alias/default/ec2"
}

variable "volume_kms_key_arn" {
  description = "KMS key used to encrypt the volumes. To be used when var.volume_kms_key_create is set to false."
  type        = string
  default     = null
}

variable "volume_kms_key_create" {
  description = "Whether or not to create a KMS key to be used for volumes encryption."
  type        = bool
  default     = true
}

variable "volume_kms_key_customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports for the KMS key to be used for volumes. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  type        = string
  default     = null
}


variable "volume_kms_key_name" {
  description = "Name prefix for the KMS key to be used for volumes. Will be suffixes with a two-digit count index."
  type        = string
  default     = null
}

variable "volume_kms_key_policy" {
  description = "A valid policy JSON document for the KMS key to be used for volumes."
  type        = string
  default     = null
}

variable "volume_kms_key_tags" {
  description = "Tags for the KMS key to be used for volumes. Will be merge with var.tags."
  default     = {}
}

####
# EBS
####

variable "external_volume_count" {
  description = "Number of external volumes to create."
  default     = 0
}

variable "external_volume_name" {
  description = "Prefix of the external volumes to create."
  default     = "extra-volumes"
}

variable "external_volume_sizes" {
  description = "Size of the external volumes."
  type        = list(number)
  default     = []
}

variable "external_volume_tags" {
  description = "Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes."
  default     = {}
}

variable "external_volume_device_names" {
  description = "Device names for the external volumes."
  type        = list(string)
  default     = [""]
}
