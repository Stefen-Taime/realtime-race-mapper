provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

variable "docker_compose" {
  default = <<-EOF
version: '3'

services:
  activemq:
    image: rmohr/activemq
    ports:
      - "61616:61616" # Port JMS
      - "8161:8161"   # Console Web ActiveMQ
      - "61613:61613" # Port STOMP

EOF
}

resource "google_compute_instance" "activemq_instance" {
  name         = "activemq-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

 metadata_startup_script = <<-EOT
    apt-get update
    apt-get install -y docker.io docker-compose
    usermod -aG docker ubuntu
    echo "${var.docker_compose}" > docker-compose.yml
    docker-compose up -d
  EOT

  tags = ["activemq-server"]
}

resource "google_compute_firewall" "activemq_firewall" {
  name    = "activemq-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["61616", "8161", "61613"]
  }

  // source_ranges = [""]
}
