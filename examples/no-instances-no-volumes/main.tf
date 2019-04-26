provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

module "no_instances_no_volumes" {
  source = "../../"

  instance_count        = 0
  external_volume_count = 0
}
