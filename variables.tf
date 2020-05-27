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

variable "num_suffix_digits" {
  description = "Number of significant digits to append to all resources of the module."
  type        = number
  default     = 2
}

variable "num_suffix_offset" {
  description = "The starting point of the numerical suffix. An offset of 1 would mean resources suffix starts at 2."
  type        = number
  default     = 0
}

####
# AutoScaling Group & EC2
####

variable "ami" {
  description = "The AMI to use for the instances or the launch template."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address for each instances (or launch template) main network interface."
  default     = false
}

variable "cpu_credits" {
  description = "The credit option for CPU usage. Can be 'standard' or 'unlimited'. T3 instances are launched as unlimited by default. T2 instances are launched as standard by default."
  type        = string
  default     = null
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance (or launch template). This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "(has no effect unless cpu_core_count is also set) If set to to 1, hyperthreading is disabled on the launched instance (or launch template). Defaults to 2 if not set. See Optimizing CPU Options for more information."
  type        = number
  default     = null
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance (or launch template) will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it."
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance (or launch template) Termination Protection."
  default     = false
}

variable "ephemeral_block_devices" {
  description = <<-DOCUMENTATION
Customize Ephemeral (also known as Instance Store) volumes on the instance (or launch template):
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
}

variable "instance_count" {
  description = "Number of instances to create. For AutoScaling Group, this value will be the desired capacity. Setting this value to 0 will disable the module."
  default     = 1
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance (or launch template). Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances."
  type        = string
  default     = null
}

variable "instance_tags" {
  description = "Tags specific to the instances (or launch template)."
  default     = {}
}

variable "instance_type" {
  description = "The type of instance (or launch template) to start. Updates to this field will trigger a stop/start of the EC2 instance though this is not true with launch template."
  default     = "t3.small"
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface of the instances or launch templlate. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "monitoring" {
  description = "If true, the launched EC2 instances (or launch template) will have detailed monitoring enabled."
  default     = false
}

variable "name" {
  description = "Name prefix of the instances themselves (tag Name) whether or not ASG is used. Will be suffixed by a var.num_suffix_digits count index."
  default     = ""
}

variable "placement_group" {
  description = "The Placement Group to start the instances (or launch template) in."
  type        = string
  default     = null
}

variable "root_block_device_delete_on_termination" {
  description = "Whether or not to delete the root block device on termination. **Note: It's is strongly discouraged to set this to false, only change this value if you have no other choice as this will leave a volume that will not be managed by terraform (even if the tag says it does) and you may end up building up costs.**"
  default     = true
}

variable "root_block_device_volume_type" {
  description = "Customize details about the root block device of the instance or launch template root volume: The type of volume. Can be 'standard', 'gp2', or 'io1'. (Default: 'gp2')."
  type        = string
  default     = null
}

variable "root_block_device_volume_size" {
  description = "Customize details about the root block device of the instance or launch template root volume: The size of the volume in gibibytes (GiB)."
  type        = string
  default     = null
}

variable "root_block_device_iops" {
  description = "The amount of provisioned IOPS. This must be set with a volume_type of 'io1'."
  type        = string
  default     = null
}

variable "root_block_device_encrypted" {
  description = "Customize details about the root block device of the instance or launch template root volume: Enables EBS encryption on the volume (Default: true). Cannot be used with snapshot_id. Must be configured to perform drift detection."
  type        = string
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID where to provision all the instances (or launch template). Can be used instead or along with var.subnet_ids."
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs where to provision the instances (or launch template). Can be used instead or along with var.subnet_id."
  type        = list(string)
  default     = [""]
}

variable "subnet_ids_count" {
  description = "How many subnet IDs in subnet_ids. Cannot be computed automatically from other variables in Terraform 0.12.X."
  default     = 0
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance or launch template will be running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command."
  default     = "default"
}

variable "user_data" {
  description = "The user data to provide when launching the instance (or launch template)."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "An object containing the list of security group IDs to associate with each instance (or launch template)."
  type        = list(list(string))
  default     = null
}

####
# AutoScaling Group
####

variable "launch_template_name" {
  description = "The name of the launch template. If you leave this blank, Terraform will auto-generate a unique name."
  type        = string
  default     = ""
}

variable "launch_template_ipv4_address_count" {
  description = "The number of secondary private IPv4 addresses to assign to a network interface. Conflicts with ipv4_addresses."
  type        = number
  default     = 0
}

variable "launch_template_tags" {
  description = "Tags to be used by the launch template. Will be merge with var.tags."
  default     = {}
}

variable "autoscaling_group_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = null
}

variable "autoscaling_group_enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = set(string)
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
  type        = set(string)
  default     = null
}

variable "autoscaling_group_target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing."
  type        = list(string)
  default     = []
}

variable "autoscaling_group_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = list(string)
  default     = null
}

variable "autoscaling_group_tags" {
  description = "Tags specific to the AutoScaling Group. Will be merged with var.tags."
  default     = {}
}

variable "autoscaling_group_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
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

variable "ec2_ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface."
  type        = list(string)
  default     = null
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

variable "ec2_volume_name" {
  description = "Tag name of the root block device of the instance."
  type        = string
  default     = "root-volume"
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
  default     = false
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
# Key Pair
####

variable "key_pair_create" {
  description = "Whether or not to create a key pair."
  default     = false
}

variable "key_pair_name" {
  description = "The name for the key pair. If this is not null and key_pair_create = false, this name will be used as a key pair."
  type        = string
  default     = null
}

variable "key_pair_public_key" {
  description = "The public key material."
  type        = string
  default     = null
}

variable "key_pair_tags" {
  description = "Tags for the key pair. Will be merged with tags."
  default     = {}
}

####
# Instance Profile
####

variable "iam_instance_profile_external_name" {
  description = "Name of an instance profile to be used by the virtual machines. If this value is given, this will be used instead of creating a new instance profile."
  type        = string
  default     = null
}

variable "iam_instance_profile_create" {
  description = "Whether or not to create an instance profile for the virtual machines."
  default     = true
}

variable "iam_instance_profile_name" {
  description = "The profile's name. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "iam_instance_profile_path" {
  description = "Path in which to create the profile. Instance profile role will share the same path."
  default     = "/"
}

variable "iam_instance_profile_iam_role_tags" {
  description = "Tags to be used for the instance profile role. Will be merged with var.tags."
  default     = {}
}

variable "iam_instance_profile_iam_role_policy_arns" {
  description = "The ARNs of the policies you want to apply to the instance profile role."
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_iam_role_policy_count" {
  description = "How many policy ARNs there are in var.instance_profile_iam_role_policy_arns. This value cannot be computed automatically in Terraform 0.12."
  type        = number
  default     = 0
}

variable "iam_instance_profile_iam_role_description" {
  description = "The description of the instance profile role."
  type        = string
  default     = "Instance profile role"
}

variable "iam_instance_profile_iam_role_name" {
  description = "The name of the instance profile role. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

####
# Elastic IP
####

variable "eip_create" {
  description = "Whether or not to create an public elastic IP per instance."
  default     = false
}

variable "extra_network_interface_eips_count" {
  description = "How many extra network interfaces will have a public elastic IP. Should be the exact number of “true” in the var.extra_network_interface_eips_enabled list."
  default     = 0
}

variable "extra_network_interface_eips_enabled" {
  description = "Respectively, for each instance, a list of boolean that indicates whether or not the extra network interface should have an elastic IP or not. Should have as many “true” as var.extra_network_interface_eips_count."
  type        = list(bool)
  default     = []
}

####
# EBS
####

variable "external_volume_count" {
  description = "Number of external volumes to create."
  default     = 0
}

variable "external_volume_device_names" {
  description = "Device names for the external volumes."
  type        = list(string)
  default     = [""]
}

variable "external_volume_name" {
  description = "Prefix of the external volumes to create."
  default     = "extra-volumes"
}

variable "external_volume_num_suffix_offset" {
  description = "The starting point of the numerical suffix for external volumes. Will combine with var.num_suffix_offset. An offset of 1 here and num_suffix_offset of 2 would mean external volumes resources suffix starts at 4."
  type        = number
  default     = 1
}

variable "external_volume_sizes" {
  description = "Size of the external volumes."
  type        = list(number)
  default     = [null]
}

variable "external_volume_tags" {
  description = "Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes."
  default     = {}
}

variable "external_volume_types" {
  description = "The type of EBS volume. Can be 'standard', 'gp2', 'io1', 'sc1' or 'st1' (Default: 'gp2'). "
  type        = list(string)
  default     = [null]
}

####
# Network Interface
####

variable "extra_network_interface_count" {
  description = "How many extra network interface to create per instance. This has no influence on the default network interface."
  type        = number
  default     = 0
}

variable "extra_network_interface_private_ips" {
  description = "List of private IPs to assign to the extra ENIs. Make sure you have as many element in the list as ENIs times the number of instances."
  type        = list(list(string))
  default     = [null]
}

variable "extra_network_interface_private_ips_counts" {
  description = "Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private_ips_count, as a primary private IP will be assiged to an ENI by default. Make sure you have as many element in the list as ENIs times the number of instances."
  type        = list(number)
  default     = [null]
}

variable "extra_network_interface_security_group_count" {
  description = "How many security groups to attach per extra ENI. This cannot be computed automatically from var.extra_network_interface_security_group_ids in terraform 0.12."
  type        = number
  default     = 0
}

variable "extra_network_interface_security_group_ids" {
  description = "List of security group IDs to assign to the extra ENIs. All ENIs will have the same security groups."
  type        = list(list(string))
  default     = null
}

variable "extra_network_interface_source_dest_checks" {
  description = "Whether to enable source destination checking for the extra ENIs. Default true."
  type        = list(bool)
  default     = [null]
}

variable "extra_network_interface_tags" {
  description = "Tags for the extra ENIs. Will be merged with tags. Tags will be shared among all extra ENIs."
  default     = {}
}
