# No instances, no volumes.

Configuration in this directory creates nothing. It is useful to disable instances on specific environments.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_key | Credentials: AWS access key. | string | n/a | yes |
| secret\_key | Credentials: AWS secret key. Pass this a variable, never write password in the code. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arns | Instance ARNs. |
| availability\_zones | Availability zones of the instances. |
| credit\_specifications | Credit specification of instance. |
| external\_volume\_arns | ARNs of all the extra volumes. |
| external\_volume\_ids | IDs of all the extra volumes. |
| ids | Instance IDs. |
| kms\_key\_id | KMS key ID used to encrypt all the extra volumes. |
| primary\_network\_interface\_ids | The IDs of the instances primary network interfaces. |
| private\_dns | Private domain names of the instances. |
| private\_ips | Private IPs of the instances. |
| public\_dns | Public domain names of the instances. |
| public\_ips | Public IPs of the instances. |
| subnet\_ids | The VPC subnet IDs where the instances are. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
