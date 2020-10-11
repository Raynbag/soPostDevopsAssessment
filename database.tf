resource "random_password" "sopost-sql-password" {
    length = 16
    special = true
}

resource "local_file" "sopost-sql-password-file" {
    content = random_password.sopost-sql-password.result
    filename = "./sopostSQLPassword"
}

resource "google_sql_database_instance" "sopost-sql-instance" {
    name = "sopost-sql-instance-${random_string.rand.result}"
    region = var.google_region

    settings {
        tier = "db-f1-micro"
    }
}

#resource "google_sql_database" "sopost-sql-db" {
#    name = "sopost-sql-db"
#    instance = google_sql_database_instance.sopost-sql-instance.name
#}

resource "google_sql_user" "sopost-wordpress-sql-user" {
    name = "wordpress"
    instance = google_sql_database_instance.sopost-sql-instance.name
    host = "%"
    password = random_password.sopost-sql-password.result
}

resource "google_compute_disk" "sopost-pd" {
    name = "sopost-pd"
    type = "pd-standard"
    zone = data.google_compute_zones.available.names[0]
}

resource "kubernetes_persistent_volume" "sopost-kpv" {
    metadata {
        name = "sopost-kpv"
    }

    spec {
        capacity = {
            storage = "1Gi"
        }
        storage_class_name = "standard"
        access_modes = ["ReadWriteOnce"]
        persistent_volume_source {
            gce_persistent_disk {
                pd_name = google_compute_disk.sopost-pd.name
            }
        }
    }
}

resource "kubernetes_persistent_volume_claim" "sopost-kpvc" {
    metadata {
        name = "sopost-kpvc"
    }

    spec {
        storage_class_name = "standard"
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "1Gi"
            }
        }
        volume_name = kubernetes_persistent_volume.sopost-kpv.metadata.0.name
    }
}