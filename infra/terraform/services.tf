resource "kubernetes_service" "discover_backend_read" {
  metadata {
    name      = "discover-backend-read"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "discover-backend-read"
      "app.kubernetes.io/part-of"    = kubernetes_namespace.backend_namespace.metadata[0].name
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }

  spec {
    selector = {
      "app" = "backend-app-read" # Must match the labels used in your backend-app-read deployment
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
    }
  }

  depends_on = [
    kubernetes_namespace.backend_namespace
  ]
}

resource "kubernetes_service" "discover_backend_write" {
  metadata {
    name      = "discover-backend-write"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "discover-backend-write"
      "app.kubernetes.io/part-of"    = kubernetes_namespace.backend_namespace.metadata[0].name
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }

  spec {
    selector = {
      "app" = "backend-app-write" # Must match the labels used in your backend-app-write deployment
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
    }
  }

  depends_on = [
    kubernetes_namespace.backend_namespace
  ]
}


resource "kubernetes_service" "redis_service" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.data_namespace.metadata[0].name
    labels = {
      app = "redis"
    }
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }

    type = "ClusterIP" # You can change this to LoadBalancer or NodePort if needed
  }
}
