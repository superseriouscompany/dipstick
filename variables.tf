variable "region" {
  default     = "eu-west-1"
  description = "AWS region to launch servers."
}

variable "access_key" {}
variable "secret_key" {}

variable "key_name" {
  default     = "terraform"
  description = "Desired name of key pair"
}

variable "public_key_path" {
  default     = "~/.ssh/id_rsa.pub"
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}
