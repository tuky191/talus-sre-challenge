resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
    labels = {
      app = "redis"
    }
  }

  spec {
    replicas = 1 # Change this to scale Redis if needed

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container { # Singular is correct for Terraform
          name  = "redis"
          image = "redis:6.2-alpine"

          port { # Singular is correct for Terraform
            container_port = 6379
          }

          volume_mount { # Singular is correct for Terraform
            name       = "redis-data"
            mount_path = "/data"
          }
          resources {
            limits = {
              memory = "256Mi" # Limits for memory and CPU
              cpu    = "500m"
            }
            requests = {
              memory = "128Mi" # Requests for memory and CPU
              cpu    = "250m"
            }
          }

        }

        # Volumes configuration
        volume { # Singular is correct for Terraform
          name = "redis-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redis_data_pvc.metadata[0].name # Corrected indexing
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis_data_pvc" {
  metadata {
    name      = "redis-data-pvc"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
