resource "digitalocean_droplet" "nginx" {
  # Obtain your ssh_key id number via your account. See Document https://developers.digitalocean.com/documentation/v2/#list-all-keys
  ssh_keys           = [98103]         # Key example
  image              = "${var.do_image_name}"
  region             = "${var.do_region}"
  size               = "512mb"
  private_networking = true
  backups            = true
  ipv6               = true
  name               = "terraform"
  count              = 3
}
