
output "kubernetes_endpoint" {
  description = "The cluster endpoint"
  sensitive   = true
  value       = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = google_container_cluster.primary.name
}

output "location" {
  value = google_container_cluster.primary.location
}

output "master_kubernetes_version" {
  description = "Kubernetes version of the master"
  value       = google_container_cluster.primary.master_version
}



output "project_id" {
  description = "The project ID the cluster is in"
  value       = var.project_id
}