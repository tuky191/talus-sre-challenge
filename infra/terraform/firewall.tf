resource "kubernetes_network_policy_v1" "allow_ingress_to_backend_on_5000" {
  metadata {
    name      = "allow-ingress-to-backend-5000"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }

      ports {
        port     = 5000
        protocol = "TCP"
      }
    }
  }
}


resource "kubernetes_network_policy_v1" "allow_ingress_to_data_on_6379" {
  metadata {
    name      = "allow-ingress-to-data-6379"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }

      ports {
        port     = 6379
        protocol = "TCP"
      }
    }
  }
}


resource "kubernetes_network_policy_v1" "allow_ingress_to_monitoring_on_3000_and_prometheus_ports" {
  metadata {
    name      = "allow-ingress-to-monitoring-3000-prometheus"
    namespace = kubernetes_namespace.monitoring_namespace.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {}
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }

      ports {
        port     = 3000
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


    ingress {
      from {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }

      ports {
        port     = 8080
        protocol = "TCP"
      }
    }
  }
}
