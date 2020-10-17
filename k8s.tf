resource "kubernetes_deployment" "sopost-k8s-deployment" {
  metadata {
    name = "wordpress"
    labels = {
      App = "wordpress"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          App = "wordpress"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress"

          env {
            name = "WORDPRESS_DB_HOST"
            value = "127.0.0.1:3306"
          }

          env {
            name = "WORDPRESS_DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.sopost-mysql-key.metadata.0.name
                key = "username"
              }
            }
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.sopost-mysql-key.metadata.0.name
                key = "password"
              }
            }
          }

          env {
            name = "WORDPRESS_DB_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.sopost-mysql-key.metadata.0.name
                key = "database"
                
              }
            }
          }

          port {
            container_port = 80
            name = "wordpress"
          }

          volume_mount {
            name = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }
        }

        container {
          name = "cloud-sql-proxy"
          image = "gcr.io/cloudsql-docker/gce-proxy:1.17"
          command = ["/cloud_sql_proxy",
            "-instances=${google_sql_database_instance.sopost-sql-instance.connection_name}=tcp:3306",
            "-credential_file=/secrets/cloudsql/key.json"]
          security_context {
            run_as_user = 2
            allow_privilege_escalation = false
            run_as_non_root = true
          }
          volume_mount {
            name = kubernetes_secret.sopost-sa-key.metadata.0.name
            mount_path = "/secrets/cloudsql"
            read_only = true
          }
        }

        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sopost-kpvc.metadata.0.name
          }
        }

        volume {
          name = kubernetes_secret.sopost-sa-key.metadata.0.name
          secret {
            secret_name = kubernetes_secret.sopost-sa-key.metadata.0.name
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "sopost-k8s-loadbalancer" {
  metadata {
    name = "wordress"
  }
  spec {
    selector = {      
      App = kubernetes_deployment.sopost-k8s-deployment.spec.0.template.0.metadata[0].labels.App      
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  } 
}

resource "kubernetes_persistent_volume_claim" "sopost-kpvc" {
    metadata {
        name = "sopost-kpvc"
    }
    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "200Gi"
            }
        }
    }
}