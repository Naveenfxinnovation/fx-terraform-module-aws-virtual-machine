provider "aws" {
  version    = ">= 3.1.0, < 4.0.0"
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key

  assume_role {
    role_arn     = "arn:aws:iam::700633540182:role/Jenkins"
    session_name = "FXTestSandbox"
  }
}
