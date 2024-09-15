resource "kubernetes_secret" "ghcr_image_pull_secret" {
  metadata {
    name      = "ghcr-login-secret"
    namespace = kubernetes_namespace.backend_namespace.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "ghcr-login-secret"
      "app.kubernetes.io/part-of"    = kubernetes_namespace.backend_namespace.metadata[0].name
      "app.kubernetes.io/managed-by" = local.terraform_source
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://ghcr.io" = {
          "username" = var.registry_username
          "password" = var.pat_token
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.pat_token}")
        }
      }
    })
  }
  lifecycle {
    ignore_changes = [data]
  }
}


