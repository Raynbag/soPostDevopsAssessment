resource "google_compute_network" "sopost-vpc" {
    name = "sopost-vpc"
    auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "sopost-vpc-subnet" {
    name = "sopost-vpc-subnet"
    network = google_compute_network.sopost-vpc.id
    region = var.google_region
    ip_cidr_range = "10.0.1.0/24"

}

resource "google_compute_firewall" "sopost-firewall-http" {
    name = "sopost-firewall-http"
    network = google_compute_network.sopost-vpc.name

    allow {
        protocol = "tcp"
        ports = ["80","22"]
    }
}