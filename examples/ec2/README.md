# EC2 examples

Configuration in this directory shows multiple examples of usage of the module using EC2.
It show multiple options, extra network interfaces, extra volumes, EIPs, external injection of resources, etc.

## Usage

```bash
$ terraform init
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
