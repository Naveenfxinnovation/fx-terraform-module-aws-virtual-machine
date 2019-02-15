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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_key | Credentials: AWS access key. | string | `"PLEASE SET THE AWS ACCESS KEY"` | no |
| region | Region. | string | `"ca-central-1"` | no |
| secret\_key | Credentials: AWS secret key. Pass this a variable, never write password in the code. | string | `"PLEASE SET THE AWS SECRET KEY. DO NOT WRITE YOUR SECRET IN THIS FILE."` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zone |  |
| external\_volume\_arns |  |
| external\_volume\_ids |  |
| id |  |
| kms\_key\_id |  |
| network\_interface\_id |  |
| primary\_network\_interface\_id |  |
| private\_dns |  |
| private\_ip |  |
| public\_dns |  |
| public\_ip |  |
| subnet\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
