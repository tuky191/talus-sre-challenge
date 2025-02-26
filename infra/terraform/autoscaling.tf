resource "kubernetes_horizontal_pod_autoscaler_v2" "backend_app_autoscaler" {
  for_each = {
    for deployment in local.deployment_roles : "${deployment.role}_${deployment.zone}" => deployment
  }

  metadata {
    name      = "backend-app-${each.value.role}-${each.value.zone}-autoscaler"
    namespace = "backend"
  }

  spec {
    min_replicas = 1
    max_replicas = 3

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.backend_app[each.key].metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.backend_app
  ]
}

