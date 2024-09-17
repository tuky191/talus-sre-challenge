provider "google" {
  credentials = base64decode(var.google_credentials)
  project     = var.google_project
  region      = var.google_region
  default_labels = {
    terraform   = local.terraform_source
    environment = var.env
  }
}

provider "google-beta" {
  credentials = base64decode(var.google_credentials)
  project     = var.google_project
  region      = var.google_region
  default_labels = {
    terraform   = local.terraform_source
    environment = var.env
  }
}


data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.gke.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}


locals {
  params           = jsondecode(file("${path.module}/params/${var.env}.json"))
  zones            = [for zone_id in local.params.zone_ids : "${var.google_region}-${zone_id}"]
  terraform_source = "tf-infra-interview"
  ranges           = local.params.ranges
  backend_image    = var.backend_image
}
