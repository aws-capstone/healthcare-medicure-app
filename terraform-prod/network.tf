/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id   = var.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name   = local.master_auth_subnetwork
      subnet_ip     = "10.4.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.subnet_name) = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

resource "google_compute_firewall" "allow_nodeport" {
  name          = "allow-nodeport-traffic-prod"
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