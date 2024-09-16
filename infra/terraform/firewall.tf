# Block all egress from backend to monitoring
resource "kubernetes_network_policy_v1" "deny_egress_to_monitoring" {
  metadata {
    name      = "deny-egress-backend-to-monitoring"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Egress"]

    egress {
      to {
        namespace_selector {
          match_labels = {
            "app.kubernetes.io/name" = "monitoring"
          }
        }
      }
      # No port exceptions, blocking all egress to monitoring
    }
  }
}

# Block egress from backend to data namespace except for Redis port (6379)
resource "kubernetes_network_policy_v1" "deny_egress_to_data" {
  metadata {
    name      = "deny-egress-backend-to-data"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Egress"]

    egress {
      to {
        namespace_selector {
          match_labels = {
            "app.kubernetes.io/name" = "data"
          }
        }
      }

      # Allow egress only for Redis on port 6379
      ports {
        port     = 6379
        protocol = "TCP"
      }
    }
  }
}
