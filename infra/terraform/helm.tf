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
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/path"
    value = "/metrics"
  }
  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = "prometheus"
  }

  create_namespace = true
  depends_on = [
    google_compute_address.this,
    helm_release.kube-prometheus-stack
  ]
}


resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "57.1.1"
  namespace  = kubernetes_namespace.monitoring_namespace.metadata[0].name
  values = [templatefile("${path.module}/prometheus-stack.tpl", {
    grafana_host = "grafana.${var.domain}"
  })]
}

data "kubernetes_service" "kube-prometheus-stack" {
  depends_on = [helm_release.kube-prometheus-stack]
  metadata {
    name = "kube-prometheus-stack"
  }
}

resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  namespace  = kubernetes_namespace.monitoring_namespace.metadata[0].name
  chart      = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  version    = "2.10.2"


  set {
    name  = "loki.nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = "monitoring-pool-a"
  }
  set {
    name  = "loki.isDefault"
    value = "false"
  }
  set {
    name  = "loki.persistence.enabled"
    value = "true"
  }
  set {
    name  = "loki.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "loki.image.tag"
    value = "2.9.3"
  }
  set {
    name  = "loki.persistence.size"
    value = "10Gi"
  }

  set {
    name  = "loki.persistence.storageClassName"
    value = "standard-rwo"
  }

  set {
    name  = "loki.config.table_manager.retention_deletes_enabled"
    value = "true"
  }

  set {
    name  = "loki.config.table_manager.retention_period"
    value = "168h"
  }

  set {
    name  = "promtail.enabled"
    value = "true"
  }

  set {
    name  = "promtail.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "promtail.persistence.enabled"
    value = "true"
  }

  set {
    name  = "promtail.persistence.size"
    value = "10Gi"
  }

  set {
    name  = "promtail.persistence.storageClassName"
    value = "standard-rwo"
  }

  set {
    name  = "promtail.nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = "monitoring-pool-a"
  }

  create_namespace = false
  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}
