prometheus-node-exporter:
  tolerations:
    - key: "node-role.kubernetes.io/master"
      effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "cloud.google.com/gke-nodepool"
                operator: In
                values:
                  - "monitoring-pool-a"

grafana:
  persistence:
    enabled: true
    type: sts
    storageClassName: "standard"
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
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    # No TLS required as Cloudflare will handle SSL termination

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "cloud.google.com/gke-nodepool"
                operator: In
                values:
                  - "monitoring-pool-a"

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
          storageClassName: "standard"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 128Gi
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "cloud.google.com/gke-nodepool"
                  operator: In
                  values:
                    - "monitoring-pool-a"
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
