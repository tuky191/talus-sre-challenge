terraform {
  required_version = ">= 1.9.5"

  cloud {
    organization = "talus-sre-challenge"
    workspaces {
      tags = ["talus-challenge"]
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.37.0"
    }
  }
}

provider "google" {
  credentials = var.google_credentials
  project     = var.google_project
  region      = var.google_region
  default_labels = {
    terraform   = local.terraform_source
    environment = var.env
  }
}

provider "google-beta" {
  credentials = var.google_credentials
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
  repository_url   = "ghcr.io/tuky191/talus-sre-challenge"
  backend_image = join(":", [
    local.repository_url,
    "latest",
  ])
}
