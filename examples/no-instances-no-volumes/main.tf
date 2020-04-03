module "no_instances_no_volumes" {
  source = "../../"

  instance_count        = 0
  external_volume_count = 0
}

