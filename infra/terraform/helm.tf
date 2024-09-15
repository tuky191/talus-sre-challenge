resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  #  version    = "4.11.0" # Use the latest stable version
  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.this.address
  }

  set {
    name  = "controller.service.annotations.cloud\\.google\\.com/load-balancer-type"
    value = "External"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
  set {
    name  = "controller.enableSnippets"
    value = "true"
  }
  set {
    name  = "controller.allowSnippetAnnotations"
    value = "true"
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  set {
    name  = "controller.admissionWebhooks.patch.enabled"
    value = "false"
  }
  create_namespace = true
  depends_on = [
    google_compute_address.this
  ]
}


resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "57.1.1"
  namespace  = kubernetes_namespace.monitoring_namespace.metadata[0].name
  values = [templatefile("${path.module}/prometheus-stack.tpl", {
    grafana_host = "grafana.talus-challenge.uk"
  })]
}

data "kubernetes_service" "kube-prometheus-stack" {
  depends_on = [helm_release.kube-prometheus-stack]
  metadata {
    name = "kube-prometheus-stack"
  }
}
