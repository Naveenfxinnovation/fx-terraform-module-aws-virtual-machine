variable "instance_count" {
  description = "Number of instances to create. Can also be 0."
  default     = 1
}

variable "instance_tags" {
  description = "Tags specific to the instances."
  default     = {}
}

variable "name" {
  description = "Name prefix of the instances. Will be suffixed by a var.num_suffix_digits count index."
  default     = ""
}

variable "num_suffix_digits" {
  description = "Number of significant digits to append to instances name. Use a string containing a leading 0."
  default     = "02"
}

variable "subnet_id" {
  description = "Subnet ID where to provision all the instances. Can be used instead or along with var.subnet_ids."
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs where to provision the instances. Can be used instead or along with var.subnet_id."
  default     = [""]
}

variable "subnet_ids_count" {
  description = "How many subnet IDs in subnet_ids. Cannot be computed automatically from other variables in Terraform 0.11.X."
  default     = 0
}

variable "tags" {
  description = "Tags to be used for all this module resources. Will be merged with specific tags."
  default     = {}
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1."
  default     = false
}

variable "vpc_security_group_ids" {
  description = "An object containing the list of security group IDs to associate with each instance."
  default     = {}
}

####
# EC2
####

variable "ami" {
  description = "The AMI to use for the instances."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address for each instances."
  default     = false
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)."
  default     = "standard"
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance. This option is only supported on creation of instance type that support CPU Options CPU Cores and Threads Per CPU Core Per Instance Type - specifying this option for unsupported instance types will return an error from the EC2 API."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "(has no effect unless cpu_core_count is also set) If set to to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set. See Optimizing CPU Options for more information."
  type        = number
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  default     = false
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach to the instance."
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it."
  default     = false
}

variable "ephemeral_block_devices" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance."
  type        = list(object({ device_name = string, virtual_name = string, no_device = string }))
  default     = []
}

variable "host_id" {
  description = "The Id of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances."
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
  default     = "t3.small"
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface."
  default     = []
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource."
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instances will have detailed monitoring enabled."
  default     = false
}

variable "placement_group" {
  description = "The Placement Group to start the instances in. "
  default     = ""
}

variable "private_ips" {
  description = "Private IPs of the instances. If set, the list must contain as many IP as the number of var.instance_count."
  default     = []
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

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command."
  default     = "default"
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  default     = ""
}



variable "volume_tags" {
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
  default     = [""]
}

variable "external_volume_tags" {
  description = "Tags for the external volumes. Will be merged with tags. Tags will be shared among all external volumes."
  default     = {}
}

variable "external_volume_device_names" {
  description = "Device names for the external volumes."
  default     = [""]
}
