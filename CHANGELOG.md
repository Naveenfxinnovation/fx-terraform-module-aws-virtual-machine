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
