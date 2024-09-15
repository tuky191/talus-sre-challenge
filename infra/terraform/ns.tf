resource "kubernetes_namespace" "backend_namespace" {
  metadata {
    name = "backend"
    labels = {
      "app.kubernetes.io/name"       = "backend"
      "app.kubernetes.io/part-of"    = "backend"
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }
}

resource "kubernetes_namespace" "monitoring_namespace" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/part-of"    = "monitoring"
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }
}

resource "kubernetes_namespace" "data_namespace" {
  metadata {
    name = "data"
    labels = {
      "app.kubernetes.io/name"       = "data"
      "app.kubernetes.io/part-of"    = "data"
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }
}
