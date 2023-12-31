provider "google" {
  credentials = file(".personal/credentials.json")
  project   = var.project
  region   = "europe-central2"
}

resource "google_compute_network" "vpc_network" {
  name             = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu               = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-central2"
  network       = google_compute_network.vpc_network.id
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "nginx-vm" 
  machine_type = "f1-micro"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Nginx
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential nginx; sudo systemctl enable nginx; sudo systemctl start nginx"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id
  }
}

resource "google_compute_firewall" "nginx" {
  name    = "nginx-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

output "nginx-url" {
  value = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:80"
}
