resource "google_service_account" "account" {
  account_id   = "${var.global_prefix}k8s-trainee-account"
  display_name = "${var.global_prefix}k8s-trainee"
}

#resource "google_service_account_key" "key" {
#  service_account_id = "${google_service_account.account.id}"
#  public_key_type    = "TYPE_X509_PEM_FILE"
#}

resource "google_project_iam_policy" "policy" {
  project     = "${var.gcp_project}"
  policy_data = "${data.google_iam_policy.policy.policy_data}"
}

data "google_iam_policy" "policy" {
  binding {
    role = "roles/container.developer"

    members = [
      "serviceAccount:${google_service_account.account.email}",
    ]
  }
}

#output "dev_service_account_key" {
#  value = "${google_service_account_key.key.private_key}"
#}
