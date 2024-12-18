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

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "~> 34.0"

  project_id                      = var.project_id
  name                            = "${local.cluster_type}-cluster"
  regional                        = true
  region                          = var.region
  network                         = module.gcp-network.network_name
  subnetwork                      = local.subnet_names[index(module.gcp-network.subnets_names, local.subnet_name)]
  ip_range_pods                   = local.pods_range_name
  ip_range_services               = local.svc_range_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  network_tags                    = [local.cluster_type]
  deletion_protection             = false
  enable_l4_ilb_subsetting        = true
  gcs_fuse_csi_driver             = true
  stateful_ha                     = false
  gke_backup_agent_config         = false
  ray_operator_config = {
    enabled            = true
    logging_enabled    = true
    monitoring_enabled = true
  }
}