prometheus-node-exporter:
  tolerations:
    - key: "node-role.kubernetes.io/master"
      effect: "NoSchedule"
  affinity: {} # Empty affinity to ensure node-exporter runs on all nodes

grafana:
  persistence:
    enabled: true
    type: sts
    storageClassName: "standard" # GKE's default storage class
    accessModes:
      - ReadWriteOnce
    size: 20Gi
    finalizers:
      - kubernetes.io/pvc-protection
  ingress:
    enabled: true
    hosts:
      - ${grafana_host}
    annotations:
      kubernetes.io/ingress.class: "nginx"
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
      nginx.ingress.kubernetes.io/ssl-redirect: "false" # Disable SSL redirection as SSL is terminated at Cloudflare
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP" # Use HTTP for backend communication with Grafana
    # No TLS section needed since Cloudflare will handle SSL termination

  sidecar:
    alerts:
      enabled: true
      label: grafana_alert
      labelValue: "1"

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: "standard" # GKE's default storage class
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 128Gi
    additionalScrapeConfigs:
      - job_name: "backend"
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_namespace]
            action: keep
            regex: backend
          - source_labels: [__meta_kubernetes_pod_container_port_number]
            action: keep
            regex: "5000"
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: pod_name
