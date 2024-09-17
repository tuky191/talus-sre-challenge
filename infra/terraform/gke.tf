locals {
  node_pools = flatten([
    for pool in local.params.pools :
    flatten([
      for pool_name, pool_info in pool : [
        for zone_id, scale in pool_info.scale : {
          name               = "${pool_name}-${zone_id}"
          machine_type       = scale.machine_type
          node_locations     = "${var.google_region}-${zone_id}"
          initial_node_count = scale.initial_node_count
          min_count          = scale.min_count
          max_count          = scale.max_count
          local_ssd_count    = 0
          spot               = true
          disk_size_gb       = 50
          disk_type          = "pd-standard"
          image_type         = "COS_CONTAINERD"
          enable_gcfs        = false
          enable_gvnic       = false
          logging_variant    = "DEFAULT"
          auto_repair        = true
          auto_upgrade       = true
          preemptible        = false
        }
      ]
    ])
  ])
}


module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 31.0"

  project_id                 = var.google_project
  name                       = "${var.google_project}-gke"
  region                     = var.google_region
  zones                      = local.zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  datapath_provider          = "ADVANCED_DATAPATH"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false
  remove_default_node_pool   = true
  deletion_protection        = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "172.16.0.0/28"
  service_account            = google_service_account.default.email
  create_service_account     = false
  gcs_fuse_csi_driver        = true
  node_pools                 = local.node_pools

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}
  }

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = {
    all = []
  }

  node_pools_tags = {
    all = []
  }
}

