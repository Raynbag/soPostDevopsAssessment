provider "google" {
    credentials = file("zeta-crossbar-292020-aea89561a7e8.json")
    project = var.google_project
    region = var.google_region
}

data "google_compute_zones" "available" {

}

resource "random_string" "rand" {
    length = 4
    upper = false
    special = false
    number = false
}

resource "google_container_cluster" "sopost-container-cluster" {
    name = "sopost-containter-cluster"
    location = data.google_compute_zones.available.names[0]
    remove_default_node_pool = true
    initial_node_count = 1
    network = google_compute_network.sopost-vpc.name
    subnetwork = google_compute_subnetwork.sopost-vpc-subnet.name
}

resource "google_container_node_pool" "sopost-node-pool" {
    name = "sopost-node-pool"
    location = data.google_compute_zones.available.names[0]
    cluster = google_container_cluster.sopost-container-cluster.name
    node_count = 1

    node_config {
        machine_type = "e2-micro"
    }
}