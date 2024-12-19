resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "subnetwork-01"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.custom-test.id
}

resource "google_compute_network" "custom-test" {
  project  = var.project_id
  name = local.network_name
  auto_create_subnetworks = false
}


resource "google_compute_firewall" "allow_nodeport" {
  name          = "allow-nodeport-traffic"
  network       = local.network_name  # Replace with your VPC name
  project       = var.project_id
  direction     = "INGRESS"
  priority      = 1000        # Adjust priority if needed
  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]  # NodePort range for TCP
  }

  allow {
    protocol = "udp"
    ports    = ["30000-32767"]  # NodePort range for UDP
  }
}