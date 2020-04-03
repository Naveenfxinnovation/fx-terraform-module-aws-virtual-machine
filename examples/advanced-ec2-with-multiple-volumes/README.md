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
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | 2.54 |

## Providers

| Name | Version |
|------|---------|
| aws | 2.54 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | Credentials: AWS access key. | `any` | n/a | yes |
| secret\_key | Credentials: AWS secret key. Pass this a variable, never write password in the code. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arns | n/a |
| availability\_zones | n/a |
| credit\_specifications | n/a |
| external\_volume\_arns | n/a |
| external\_volume\_ids | n/a |
| ids | n/a |
| kms\_key\_id | n/a |
| primary\_network\_interface\_ids | n/a |
| private\_dns | n/a |
| private\_ips | n/a |
| public\_dns | n/a |
| public\_ips | n/a |
| subnet\_ids | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
