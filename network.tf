resource "google_compute_network" "net" {
  name                    = "${var.global_prefix}net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.global_prefix}subnet"
  region        = "${var.gcp_region}"
  ip_cidr_range = "10.123.0.0/16"
  network       = "${google_compute_network.net.self_link}"
}
