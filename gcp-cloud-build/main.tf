terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# Update these values
locals {
  project_id  = "my-gcp-project"
  region      = "asia-south1"
  zone        = "asia-south1-a"
  vm_name     = "terraform-vm"
  machine_type = "e2-medium"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

resource "google_compute_instance" "vm" {
  name         = local.vm_name
  machine_type = local.machine_type
  zone         = local.zone

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Assign ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOT

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "vm_name" {
  value = google_compute_instance.vm.name
}

output "vm_internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip
}

output "vm_external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
