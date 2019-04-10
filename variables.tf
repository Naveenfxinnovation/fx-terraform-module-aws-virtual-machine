variable "ami" {
  description = "AMI to be used."
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public IP to the instance."
  default     = false
}

variable "instance_count" {
  description = "Number of instances to create. Can alsot be 0."
  default     = 1
}

variable "instance_types" {
  description = "Instance types."
  type        = "list"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  default     = false
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance."
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "name" {
  description = "Name of the instance."
  default     = ""
}

variable "key_name" {
  description = "Key name for the instance."
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "private_ip" {
  description = "Private IP of the instance."
  default     = ""
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  default     = []
}

variable "source_dest_check" {
  description = "Source/destination AWS check."
  default     = "true"
}

variable "subnet_id" {
  description = "Subnet id."
  default     = ""
}

variable "tags" {
  description = "Tags of the instance."
  default     = {}
}

variable "user_data" {
  description = "User data of the instance."
  default     = ""
}

variable "volume_tags" {
  description = "Tags of the root volume of the instance. Will be merged with tags."
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "Security groups."
  default     = []
}

variable "external_volume_count" {
  description = "Number of external volumes to create."
  default     = 0
}

variable "external_volume_name_suffix" {
  description = "Suffix of the external volumes to create."
  default     = "extra-volumes"
}

variable "external_volume_kms_key_create" {
  description = "Whether or not to create KMS key. Cannot be computed from other variable in terraform 0.11.0."
  default     = false
}

variable "external_volume_kms_key_arn" {
  description = "KMS key used to encrypt the external volume."
  default     = ""
}

variable "external_volume_kms_key_tags" {
  description = "Tags for the KMS key to be used for externale volume"
  default     = {}
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
