/* AWS */
variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS region to launch servers."
}

variable "access_key" {}
variable "secret_key" {}

variable "aws_key_name" {
  default     = "terraform"
  description = "Desired name of key pair"
}

variable "aws_public_key_path" {
  default     = "~/.ssh/id_rsa.pub"
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

/* GCP */
variable "gcp_region" {
  default = "europe-west1"
}

variable "gcp_region_zone" {
  default = "europe-west1-b"
}

variable "project_name" {
  default = "emerald-mission-151101"
  description = "The ID of the Google Cloud project"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "./gcp.json"
}

variable "gcp_image_name" {
  default = "packer-1480653901"
}

variable "gcp_public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/id_rsa.pub"
}

/* DO */
variable "do_image_name" {
  default = "21268999"
}

variable "do_region" {
  default = "lon1"
}
