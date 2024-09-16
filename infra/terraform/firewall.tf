resource "kubernetes_network_policy_v1" "allow_ingress_to_backend" {
  metadata {
    name      = "allow-ingress-to-backend"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }

      ports {
        port     = 5000
        protocol = "TCP"
      }
    }
  }
}


resource "kubernetes_network_policy_v1" "allow_ingress_to_data" {
  metadata {
    name      = "allow-ingress-to-data"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.backend_namespace.metadata[0].name
          }
        }
      }

      ports {
        port     = 6379
        protocol = "TCP"
      }
    }
  }
}


resource "kubernetes_network_policy_v1" "allow_ingress_to_monitoring" {
  metadata {
    name      = "allow-ingress-to-monitoring"
    namespace = kubernetes_namespace.monitoring_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }

      ports {
        port     = 3000
        protocol = "TCP"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.monitoring_namespace.metadata[0].name
          }
        }
      }

      ports {
        port     = 3100
        protocol = "TCP"
      }
    }

    ingress {
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }

      ports {
        port     = 9090
        protocol = "TCP"
      }
    }
  }
}
