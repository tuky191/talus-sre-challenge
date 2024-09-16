resource "google_compute_address" "this" {
  name   = "${var.google_project}-ip"
  region = var.google_region
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.google_project
  network_name = "${var.google_project}-network"
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name   = "${var.google_project}-subnet"
      subnet_ip     = local.ranges.subnetwork
      subnet_region = var.google_region
    },
  ]
  secondary_ranges = {
    "${var.google_project}-subnet" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = local.ranges.pods
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = local.ranges.services
      },
    ]
  }
}

resource "google_compute_router" "nat_router" {
  name    = "${var.google_project}-nat-router"
  network = module.vpc.network_name
  region  = var.google_region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.google_project}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.google_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}




resource "kubernetes_ingress_v1" "ingress_backend_get" {
  metadata {
    name      = "ingress-get"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                     = "nginx",
      "nginx.ingress.kubernetes.io/limit-methods"       = "GET",
      "nginx.ingress.kubernetes.io/enable-cors"         = "true",
      "nginx.ingress.kubernetes.io/cors-allow-origin"   = "*",
      "nginx.ingress.kubernetes.io/cors-allow-methods"  = "GET, PUT, POST, DELETE, PATCH, OPTIONS",
      "nginx.ingress.kubernetes.io/cors-allow-headers"  = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range",
      "nginx.ingress.kubernetes.io/cors-expose-headers" = "Content-Length,Content-Range"
    }
  }

  spec {
    rule {
      host = "backend.talus-challenge.uk"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "discover-backend-read"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "ingress_backend_post" {
  metadata {
    name      = "ingress-post"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                     = "nginx",
      "nginx.ingress.kubernetes.io/limit-methods"       = "POST",
      "nginx.ingress.kubernetes.io/enable-cors"         = "true",
      "nginx.ingress.kubernetes.io/cors-allow-origin"   = "*",
      "nginx.ingress.kubernetes.io/cors-allow-methods"  = "GET, PUT, POST, DELETE, PATCH, OPTIONS",
      "nginx.ingress.kubernetes.io/cors-allow-headers"  = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range",
      "nginx.ingress.kubernetes.io/cors-expose-headers" = "Content-Length,Content-Range"
    }
  }

  spec {
    rule {
      host = "backend.talus-challenge.uk"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "discover-backend-write"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
