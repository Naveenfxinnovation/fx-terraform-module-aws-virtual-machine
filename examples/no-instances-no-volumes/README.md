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
## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
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
