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
| region | Region. | string | `"ca-central-1"` | no |
| secret\_key | Credentials: AWS secret key. Pass this a variable, never write password in the code. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zone |  |
| external\_volume\_arns |  |
| external\_volume\_ids |  |
| id |  |
| kms\_key\_id |  |
| primary\_network\_interface\_id |  |
| private\_dns |  |
| private\_ip |  |
| public\_dns |  |
| public\_ip |  |
| subnet\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
