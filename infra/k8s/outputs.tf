
# GKE outputs

output "service_account" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "namespace" {
  value = "${kubernetes_service_account.tiller.metadata.0.namespace}"
}
