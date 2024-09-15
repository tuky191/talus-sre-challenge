resource "kubernetes_stateful_set" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
    labels = {
      app = "redis"
    }
  }

  spec {
    service_name = kubernetes_service.redis_service.metadata[0].name
    replicas     = 1

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
        node_selector = {
          "cloud.google.com/gke-nodepool" = join("-", ["data-pool", "a"])
        }
        container {
          name  = "redis"
          image = "redis:6.2-alpine"

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }

          resources {
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "128Mi"
              cpu    = "250m"
            }
          }
        }

        volume {
          name = "redis-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.redis_data_pvc.metadata[0].name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "redis-data"
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
