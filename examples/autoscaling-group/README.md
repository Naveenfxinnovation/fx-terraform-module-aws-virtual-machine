# AutoScaling Group example

Configuration in this directory creates an AutoScaling group with various options.

## Usage

To run this example you need to execute:

```bash
$ terraform init
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
| iam\_instance\_profile\_arn | n/a |
| iam\_instance\_profile\_iam\_role\_arn | n/a |
| iam\_instance\_profile\_iam\_role\_id | n/a |
| iam\_instance\_profile\_iam\_role\_unique\_id | n/a |
| iam\_instance\_profile\_id | n/a |
| iam\_instance\_profile\_unique\_id | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
