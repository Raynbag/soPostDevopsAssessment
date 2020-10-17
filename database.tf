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
        ip_configuration {
          ipv4_enabled = true
        }
    }
}

resource "google_sql_database" "sopost-sql-db" {
   name = "sopost-sql-db"
   instance = google_sql_database_instance.sopost-sql-instance.name
}

resource "google_sql_user" "sopost-wordpress-sql-user" {
    name = "wordpress"
    instance = google_sql_database_instance.sopost-sql-instance.name
    host = "%"
    password = random_password.sopost-sql-password.result
}