11.3.0
==================

* feat: allow to specify iops and throughput for extra volumes if the volume type permit it
* chore: bump pre-commit hooks

11.2.0
==================

* feat: increase the maximum number of extra volumes allowed
* chore: bump pre-commit hooks

11.1.0
==================

* feat: add support for gp3 disks
* chore: bump pre-commit hooks

11.0.0
=====

* feat (BREAKING): upgrades to support Terraform 0.13 properly
* feat (BREAKING): adds validation to all the variables
* feat: adds `aws_autoscaling_schedule` to add ASG schedules
* feat: adds `var.volume_kms_key_external_exist`
* refactor (BREAKING): removes convoluted loops to handle module count
* refactor (BREAKING): renames `ec2_external_primary_network_insterface_id` to `var.ec2_external_primary_network_interface_id`
* refactor (BREAKING): removes `var.use_external_primary_network_interface`
* refactor (BREAKING): changes multiple variables types from lists to simple types
* refactor (BREAKING): rename `external*volumes` to `extra*volumes`
* refactor (BREAKING): rename `this` extra NICs resources to `this_extra`
* refactor (BREAKING): remove `iam_instance_profile_external_name` to use `iam_instance_profile_name` directly
* refactor (BREAKING): all EC2 outputs are now singular instead of plural
* refactor (BREAKING): `var.use_num_suffix` is now `true` by default
* refactor (BREAKING): transform EIP outputs in objects with key primary and extra
* refactor (BREAKING): rename and change in objects `extra_network_interface_XXX` to `network_interface_XXX` containing both primary and extra
* refactor (BREAKING): removes `extra_network_interface_public_ips` output
* refactor (BREAKING): most names are now not incremental anymore, except extra volumes and NICs
* refactor: Split resources into more digestable, smaller files
* doc: changes most variables descriptions to be more accurate and give more insight
* doc: updates README: update what the module does and improves `limitations` section
* maintenance: pins pre-commit dependencies to latest versions
* fix: fix the ability to inject external primary network interface for EC2
* fix: also use `var.prefix` for IAM Role and Instance Profile
* fix: creates a KMS grant when KMS and ASG is used, to allow ASG to use the key for decrypting volumes

10.0.0
=====

* feat (BREAKING): do not create instance profile by default
* feat (BREAKING): default instance type is changes to t3.small to cheaper t3.nano
* feat: if no AMI is specified, now uses the latest amazon linux AMI
* test: adds a default baby example
* doc: improves some variables description

9.0.0
=====

* feat (BREAKING): add prefix (`volume_kms_key_alias` is now automaticaly prefixed by `alias/`)
* feat: Add external primary network inteface to use an external ENI for EC2 instances
* chore: fix provider assume role

8.0.0
=====

* feat(BREAKING): uses external resource to create primary network interface for EC2
* feat(BREAKING): uses external resource to create primary EIP when needed
* feat(BREAKING): removes eip_create as it now equals associate_public_ip_address
* feat: adds ipv4_address_count to set primary netint IPv4 addresses
* feat: adds description to primary network interface
* feat: adds generic description to extra network interfaces
* feat: adds names to the network interface and extra network interfaces
* refactor: removes unused launch_template_ipv4_address_count

7.1.2
=====

* fix: adds suffixes for external volumes and KMS keys when us_num_suffix=true

7.1.1
=====

* fix: typo in versions.tf to be usable with terraform 0.13

7.1.0
=====

* feat: removes managed-by=Terraform tags for ASG instances
* fix: makes sure zipmap don’t makes error when a resources is destroyed with target

7.0.0
=====

* feat: Add a default name for the root block device of EC2 instances
* feat (BREAKING): start external volume index at 2

6.2.0
=====

* feat: Allow for delete on termination on root block device as a variable

6.1.1
=====

* fix: fix AutoScaling group creation with latest AWS provider
* fix: fix `cpu_options` for ASG
* fix: fix not working dynamic blocks throughout the module
* tech: update possible version for AWS provider to 2.60 and up
* test: rename `no-instances-no-volumes` example to `disabled`
* test: add an example with Windows machine

6.1.0
=====

* feat: allows to specify a numeric suffix offset

6.0.4
=====

* tech: Add example to test asg without ALB/NLB
* fix: Changed type of some variables

6.0.3
=====

* fix: output KMS key ID when it is created by the module
* fix: makes `ephemeral_block_devices` a list type
* test: checks idempotency when using `ec2_volume_tags` and `external_volume_tags`

6.0.2
=====

* fix: uses /dev/sda1 as root block device

6.0.1
=====

* fix: uses var.name for instance name even with launch template
* refactor: removes deprecated variable `iam_instance_profile`
* doc: better describes variables for both instance and launch template

6.0.0
=====

* refactor (BREAKING): replace deprecated `launch_configuration` by `launch_template`
* refactor (BREAKING): renames some EC2-specific variable `ec2_` prefix for what is shared with launch template
* fix: do not create extra network interfaces when ASG is selected
* fix: do not create EIP when ASG is selected

5.0.0
=====

* feat (BREAKING): handle IAM instance profile

4.1.0
=====

* feat: handle elastic IPs for EC2 instances
* feat: handle elastic IPs for network interfaces

4.0.1
=====

* fix: do not fetch some default resources on AWS account when not needed

4.0.0
=====

* feat: handle multiple `aws_network_interface` resources
* refactor (BREAKING deployed resources): makes outputs map of lists for volumes, will change the order of creation of volumes
* refactor: prefix EC2-specific outputs with `ec2_`
* tech: adds validation with terraform tflint

3.0.0
=====

* fix: BREAKING Use default KMS key for volume encryption by default

2.1.1
=====

* fix: required version in greater or equal to 2.54, not 2.54.0
* fix: suffix name contain spaces instad of number

2.1.0
=======

* feat: handle `aws_key_pair` resource locally or externally
* feat: adds a tag for all resources: Provider=Terraform

2.0.0
=======

* refactor (BREAKING): merge the two `aws_instance` resources (t instance and the other) to one single resource.
* refactor: removes `credit_specifications` from outputs because it’s also variable.
* fix: do not create a KMS key if KMS ARN is given.
* fix: lowers the risk of conflicting tags in AutoScaling Group that would break idempotency

1.1.0
=======

* feat: handle AutoScaling group and Launch Configuration resources
* feat: handle volume types for external volumes
* refactor: better handling of numeric suffix, toggleable by setting it to 0 and using numeric value instead of string
* refactor: reorganizes variables to separate EC2-specific, ASG-specific and common

1.0.0
=======

* feat: adds more accurate type validation for variables
* feat: adds `host_id`, `cpu_core_count`, `cpu_threads_per_core` arguments for EC2
* feat: adds `customer_master_key_spec` and `policy` arguments for KMS key for all volumes
* feat: now possible to encrypt root volume with the same KMS key as external volumes
* feat: If no security group is given, VPC default security group is used
* refactor: adapts code to work with terraform0.12
* refactor: `external_volume_kms_***` variables are now `volume_kms_***` because the key can be used for root device
* refactor: Remove ebs_block_device as we should always use external block device in this module
* test: adds test for modifying root block device
* tech: bumps pre-commit config versions
* doc: adds CHANGELOG

0.0.0
=======

* Fork from terraform-module-aws-ec2 module
