locals {
  cluster_type           = "capstone-projecr2-prod-public"
  network_name           = "capstone-projecr2-prod-public-network"
  subnet_name            = "capstone-projecr2-prod-public-subnet"
  master_auth_subnetwork = "capstone-projecr2-prod-public-master-subnet"
  pods_range_name        = "ip-range-pods-capstone-projecr2-prod-public"
  svc_range_name         = "ip-range-svc-capstone-projecr2-prod-public"
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
  network                         = module.gcp-network.network_name
  subnetwork                      = local.subnet_names[index(module.gcp-network.subnets_names, local.subnet_name)]   
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1
  node_config{
    disk_size_gb = 25
    advanced_machine_features{
      threads_per_core = 0
      enable_nested_virtualization = null
    } 

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