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

loki:
  enabled: true
  persistence:
    enabled: true
    size: 10Gi
    storageClassName: "standard-rwo"
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 168h # Retain logs for 7 days

grafana:
  persistence:
    enabled: true
    type: sts
    storageClassName: "standard-rwo"
    accessModes:
      - ReadWriteOnce
    size: 10Gi
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
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: "standard-rwo"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: "cloud.google.com/gke-nodepool"
                  operator: In
                  values:
                    - "monitoring-pool-a"
