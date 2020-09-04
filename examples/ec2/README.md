# Standard EC2 with another data volume

Configuration in this directory creates a standard EC2 with an additional EBS volume.

## Usage

```bash
$ terraform init
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
