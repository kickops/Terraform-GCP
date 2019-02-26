provider "google" {
  credentials = "${file(var.gcp_service_account_key)}"
  project = "${var.gcp_project}"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_zone}"
}
