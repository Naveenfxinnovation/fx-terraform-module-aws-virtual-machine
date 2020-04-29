# Multiple EC2, multiple volumes, multiple network interfaces

Configuration in this directory creates multiple EC2 with multiple volumes and multiple extra network interfaces.

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
| aws | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | n/a | `string` | n/a | yes |
| secret\_key | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | n/a |
| autoscaling\_group\_id | n/a |
| availability\_zones | n/a |
| ec2\_arns | n/a |
| ec2\_ids | n/a |
| ec2\_primary\_network\_interface\_ids | n/a |
| ec2\_private\_dns | n/a |
| ec2\_private\_ips | n/a |
| ec2\_public\_dns | n/a |
| ec2\_public\_ips | n/a |
| eip\_ids | n/a |
| eip\_network\_interfaces | n/a |
| eip\_private\_dns | n/a |
| eip\_private\_ips | n/a |
| eip\_public\_dns | n/a |
| eip\_public\_ips | n/a |
| external\_volume\_arns | n/a |
| external\_volume\_ids | n/a |
| extra\_network\_interface\_ids | n/a |
| extra\_network\_interface\_mac\_addresses | n/a |
| extra\_network\_interface\_private\_ips | n/a |
| extra\_network\_interface\_public\_ips | n/a |
| iam\_instance\_profile\_arn | n/a |
| iam\_instance\_profile\_iam\_role\_arn | n/a |
| iam\_instance\_profile\_iam\_role\_id | n/a |
| iam\_instance\_profile\_iam\_role\_unique\_id | n/a |
| iam\_instance\_profile\_id | n/a |
| iam\_instance\_profile\_unique\_id | n/a |
| key\_pair\_fingerprint | n/a |
| key\_pair\_id | n/a |
| key\_pair\_name | n/a |
| kms\_key\_id | n/a |
| subnet\_ids | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
