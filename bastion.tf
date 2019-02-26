data "template_file" "startup_script" {
  template = <<EOF
apt-get update
apt-get install -y docker.io python-pip
usermod -aG docker ubuntu
pip install docker-compose

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

apt-get install -y apt-transport-https
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get update && apt-get install -y google-cloud-sdk

curl -s https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens > /usr/local/bin/kubens
chmod +x /usr/local/bin/kubens
sudo -u ubuntu curl -s https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh > /home/ubuntu/.kube-ps1.sh
sudo -u ubuntu echo "source /home/ubuntu/.kube-ps1.sh" >> /home/ubuntu/.bashrc
sudo -u ubuntu echo "PS1='[\u@\h \W \$(kube_ps1)]\\$ '" >> /home/ubuntu/.bashrc
sudo -u ubuntu echo "kubeoff" >> /home/ubuntu/.bashrc

sudo -u ubuntu gcloud config configurations create training --activate
sudo -u ubuntu gcloud config set core/project $${project}
sudo -u ubuntu gcloud config set compute/region $${region}
sudo -u ubuntu gcloud config set compute/zone $${zone}
sudo -u ubuntu gcloud container clusters get-credentials $${cluster_name}
EOF

  vars {
     cluster_name = "${var.global_prefix}${var.cluster_name}"
     zone         = "${var.gcp_zone}"
     region       = "${var.gcp_region}"
     project      = "${var.gcp_project}"
  }
}

resource "google_compute_instance" "compute-inst" {
  zone = "${var.gcp_zone}"
  name = "${var.global_prefix}training-${count.index + 1}"
  machine_type = "${var.bastion_machine_type}"
  count   = "${var.bastion_count}"
  service_account {
    email = "${google_service_account.account.email}"
    scopes = [ "cloud-platform" ]
  }
  boot_disk {
    initialize_params {
      image = "${var.bastion_image_name}"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.self_link}"
    access_config {
    }
  }
  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    startup-script = "${data.template_file.startup_script.rendered}"
  }

  tags = [ "bastion" ]
}

resource "google_compute_firewall" "fw-ssh" {
  name    = "${var.global_prefix}tcp-ssh"
  network = "${google_compute_network.net.self_link}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = "${var.source_ip_cidr}"
  target_tags = [ "bastion" ]
}

resource "google_compute_firewall" "fw-user-ports" {
  name    = "${var.global_prefix}tcp-user-ports"
  network = "${google_compute_network.net.self_link}"
  allow {
    protocol = "tcp"
    ports    = "${var.bastion_ports}"
  }
  source_ranges = "${var.source_ip_cidr}"
  target_tags = [ "bastion" ]
}

output "instance_ips" {
  value = ["${google_compute_instance.compute-inst.*.network_interface.0.access_config.0.nat_ip}"]
}