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
