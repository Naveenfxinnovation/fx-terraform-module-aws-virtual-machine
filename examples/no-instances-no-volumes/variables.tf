variable "region" {
  description = "Region."
  default     = "ca-central-1"
}

variable "access_key" {
  description = "Credentials: AWS access key."
}

variable "secret_key" {
  description = "Credentials: AWS secret key. Pass this a variable, never write password in the code."
}
