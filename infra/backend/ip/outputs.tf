output "ip_reserved" {
  value       = "${google_compute_address.default.address}"
  description = "Ip reserved for load balancers"
}
