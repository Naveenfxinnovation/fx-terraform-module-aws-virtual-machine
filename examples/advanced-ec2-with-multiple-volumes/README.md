# Advanced EC2 with multiple data volumes

Configuration in this directory creates an EC2 with lots of options.
It also create multiple EBS volumes and attached them to the instance.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | 2.54 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| access\_key | Credentials: AWS access key. | `any` | n/a | yes |
| secret\_key | Credentials: AWS secret key. Pass this a variable, never write password in the code. | `any` | n/a | yes |

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
