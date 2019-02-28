# network VPC output
output "vpc_name" {
  value       = "${module.vpc.vpc_name}"
  description = "The unique name of the network"
}

# subnet cidr ip range
output "ip_cidr_range" {
  value       = "${module.subnet.ip_cidr_range}"
  description = "Export created CICDR range"
}

# GKE outputs
output "endpoint" {
  value       = "${module.gke.endpoint}"
  description = "Endpoint for accessing the master node"
}
output "ip_reserved" {
  value       = "${module.ip.ip_reserved}"
  description = "Ip reserved for load balancers"
}
