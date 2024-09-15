# Step 1: Filter zones that have nodes deployed (i.e., initial_node_count > 0)
locals {
  valid_zones = {
    for zone_id, scale in local.params.pools[0]["backend-pool"].scale : zone_id => scale
    if scale.initial_node_count > 0
  }
}

# Step 2: Define roles (read/write) for each valid zone
locals {
  deployment_roles = flatten([
    for zone_id in keys(local.valid_zones) : [
      {
        role     = "read"
        zone     = zone_id
        replicas = local.params.backend.replicas.read
      },
      {
        role     = "write"
        zone     = zone_id
        replicas = local.params.backend.replicas.write
      }
    ]
  ])
}

resource "kubernetes_deployment" "backend_app" {
  for_each = {
    for deployment in local.deployment_roles : "${deployment.role}_${deployment.zone}" => deployment
  }

  metadata {
    name      = "backend-app-${each.value.role}-${each.value.zone}"
    namespace = "backend"
    labels = {
      app  = "backend-app-${each.value.role}"
      zone = join("-", [var.google_region, each.value.zone])
    }
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app  = "backend-app-${each.value.role}"
        zone = join("-", [var.google_region, each.value.zone])
      }
    }

    template {
      metadata {
        labels = {
          app  = "backend-app-${each.value.role}"
          zone = join("-", [var.google_region, each.value.zone])
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "topology.kubernetes.io/zone"
                  operator = "In"
                  values   = ["${var.google_region}-${each.value.zone}"]
                }
              }
            }
          }
        }

        container {
          name  = "flask-app"
          image = local.backend_image

          port {
            container_port = 5000
          }

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          env {
            name  = "APP_ROLE"
            value = each.value.role
          }

          env {
            name  = "REDIS_HOST"
            value = "redis.data.svc.cluster.local" # Update as needed
          }
        }
      }
    }
  }
}
