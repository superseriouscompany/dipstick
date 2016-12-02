variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "nginx" {
  ami           = "ami-e8c49d9b"
  instance_type = "t2.nano"
}
