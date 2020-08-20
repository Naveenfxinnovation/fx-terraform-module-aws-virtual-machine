resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
}

module "example" {
  source = "../../"

  prefix = random_string.this.result
}
