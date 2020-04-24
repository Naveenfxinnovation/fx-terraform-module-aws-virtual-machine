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
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 2 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | n/a | `string` | n/a | yes |
| secret\_key | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam\_instance\_profile\_external\_name | n/a |
| iam\_instance\_profile\_iam\_role\_arn | n/a |
| iam\_instance\_profile\_iam\_role\_id | n/a |
| iam\_instance\_profile\_iam\_role\_unique\_id | n/a |
| iam\_instance\_profile\_id | n/a |
| iam\_instance\_profile\_unique\_id | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
