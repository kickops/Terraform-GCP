resource "google_container_cluster" "k8cluster" {
  name               = "${var.global_prefix}${var.cluster_name}"
  zone               = "${var.gcp_zone}"
  initial_node_count = "${var.cluster_initial_worker_node_count}"
  network            = "${google_compute_network.net.self_link}"
  subnetwork         = "${google_compute_subnetwork.subnet.self_link}"
  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
    #http_load_balancing {
    #  # Disable GKE ingress controller
    #  disabled = true
    #}
  }

  node_config {
    machine_type = "${var.cluster_machine_type}"
    tags         = [ "kubernetes" ]
  }
}

resource "google_compute_firewall" "fw-k8s-eph-ports" {
  name    = "${var.global_prefix}tcp-ephemeral-ports"
  network = "${google_compute_network.net.self_link}"

  allow {
    protocol = "tcp"
    ports    = "${var.cluster_ports}"
  }
  source_ranges = "${var.source_ip_cidr}"
  target_tags = [ "kubernetes" ]
}
