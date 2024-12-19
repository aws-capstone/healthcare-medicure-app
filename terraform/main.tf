locals {
  cluster_type           = "capstone-project2-public"
  network_name           = "capstone-project2-public-network"
  subnet_name            = "capstone-project2-public-subnet"
  master_auth_subnetwork = "capstone-project2-public-master-subnet"
  pods_range_name        = "ip-range-pods-capstone-project2-public"
  svc_range_name         = "ip-range-svc-capstone-project2-public"
  subnet_names           = [for subnet_self_link in module.gcp-network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

resource "google_container_cluster" "primary" {
  name     = "${local.cluster_type}-cluster"
  location = var.region
  project  = var.project_id
  network                         = google_compute_network.custom-test.name
  subnetwork                      = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name   
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1
  node_config{
    disk_size_gb = 25
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.primary.id
  location = var.region
  project  = var.project_id  
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 25

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}