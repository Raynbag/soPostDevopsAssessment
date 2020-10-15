data "google_client_config" "provider" {}

data "google_compute_zones" "available" {}

provider "google" {
    credentials = file("zeta-crossbar-292020-aea89561a7e8.json")
    project = var.google_project
    region = var.google_region
}

provider "kubernetes" {
    load_config_file = false
    
    host = "https://${google_container_cluster.sopost-container-cluster.endpoint}"

    client_certificate = base64decode(google_container_cluster.sopost-container-cluster.master_auth.0.client_certificate)
    client_key = base64decode(google_container_cluster.sopost-container-cluster.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.sopost-container-cluster.master_auth.0.cluster_ca_certificate)
    token = data.google_client_config.provider.access_token

}

resource "random_string" "rand" {
    length = 4
    upper = false
    special = false
    number = false
}

resource "google_service_account" "sopost-sa" {
    account_id = "sopost-sa"
    display_name = "sopost-sa"
}

resource "google_project_iam_binding" "sopost-iam-binding" {
  project = var.google_project
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.sopost-sa.email}",
  ]
}

resource "google_service_account_key" "sopost-sak" {
  service_account_id = google_service_account.sopost-sa.name
}