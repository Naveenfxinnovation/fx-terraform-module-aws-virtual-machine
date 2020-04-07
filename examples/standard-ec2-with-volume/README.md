# Standard EC2 with another data volume

Configuration in this directory creates a standard EC2 with an additional EBS volume.

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
| access\_key | n/a | `string` | n/a | yes |
| secret\_key | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arns | n/a |
| autoscaling\_group\_arn | n/a |
| autoscaling\_group\_availability\_zones | n/a |
| autoscaling\_group\_id | n/a |
| availability\_zones | n/a |
| external\_volume\_arns | n/a |
| external\_volume\_ids | n/a |
| ids | n/a |
| key\_pair\_fingerprint | n/a |
| key\_pair\_id | n/a |
| key\_pair\_name | n/a |
| kms\_key\_id | n/a |
| launch\_configuration\_arn | n/a |
| launch\_configuration\_ebs\_block\_devices | n/a |
| launch\_configuration\_id | n/a |
| launch\_configuration\_name | n/a |
| primary\_network\_interface\_ids | n/a |
| private\_dns | n/a |
| private\_ips | n/a |
| public\_dns | n/a |
| public\_ips | n/a |
| subnet\_ids | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
