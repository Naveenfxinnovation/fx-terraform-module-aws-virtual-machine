# AutoScaling Group example

Configuration in this directory creates an AutoScaling group with various options, and it creates an autoscaling group without the LB portion.

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
| no\_target\_groups\_and\_no\_external\_volumes | n/a |
| with\_nlb\_and\_external\_volumes | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
