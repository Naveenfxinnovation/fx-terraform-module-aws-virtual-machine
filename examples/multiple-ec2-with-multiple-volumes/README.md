# Multiple EC2 with multiple volumes

Configuration in this directory creates multiple EC2 with multiple volumes.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Outputs

| Name | Description |
|------|-------------|
| availability\_zone |  |
| external\_volume\_arns |  |
| external\_volume\_ids |  |
| ids |  |
| kms\_key\_id |  |
| primary\_network\_interface\_ids |  |
| private\_dns |  |
| private\_ips |  |
| public\_dns |  |
| public\_ips |  |
| subnet\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
