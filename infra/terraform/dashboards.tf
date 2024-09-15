resource "kubernetes_config_map" "dashboard" {
  for_each = { for f in fileset("${path.module}/dashboards", "*.json") : f => trimsuffix(f, ".json") }
  metadata {
    name = "dashboard-${lower(replace(each.key, "_", "-"))}"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "${each.key}" = file("${path.module}/dashboards/${each.key}")
  }
}
