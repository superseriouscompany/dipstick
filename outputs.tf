output "elb_address" {
  value = "${aws_elb.web.dns_name}"
}

output "gcp_address" {
  value = "${google_compute_forwarding_rule.default.ip_address}"
}

output "gcp_instances" {
  value = "${join(" ", google_compute_instance.nginx.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}
