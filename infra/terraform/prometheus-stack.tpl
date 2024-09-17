prometheus-node-exporter:
  tolerations:
    - key: "node-role.kubernetes.io/master"
      effect: "NoSchedule"
  nodeSelector:
    cloud.google.com/gke-nodepool: "monitoring-pool-a"

grafana:
  admin:
    existingSecret: grafana-admin-secret 
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

  nodeSelector:
    cloud.google.com/gke-nodepool: "monitoring-pool-a"

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
    nodeSelector:
      cloud.google.com/gke-nodepool: "monitoring-pool-a"
