
# resource "kubernetes_service" "discovery_service" {
#   for_each = { for k, v in local.aggregatedServices : k => v }

#   metadata {
#     name      = "discover-${each.value.chain_name}-${each.value.node_type}"
#     namespace = kubernetes_namespace.chains_namespace.metadata[0].name
#     labels = {
#       "app.kubernetes.io/name"       = "discover-${each.value.chain_name}-${each.value.node_type}"
#       "app.kubernetes.io/part-of"    = kubernetes_namespace.chains_namespace.metadata[0].name
#       "app.kubernetes.io/managed-by" = local.terraform_source
#     }
#   }

#   spec {
#     selector = {
#       "chain-type" = "${each.value.chain_name}-${each.value.node_type}"
#     }

#     type       = "ClusterIP"
#     cluster_ip = "None"

#     dynamic "port" {
#       for_each = [for port in local.port_order : each.value.port_mappings[port]]
#       content {
#         name        = port.value.name
#         port        = port.value.containerPort
#         target_port = port.value.containerPort
#         protocol    = port.value.protocol
#       }
#     }
#   }

#   depends_on = [
#     module.gke.google_container_node_pool, kubernetes_namespace.chains_namespace
#   ]
# }
