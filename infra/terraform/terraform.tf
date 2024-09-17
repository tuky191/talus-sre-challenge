terraform {
  required_version = ">= 1.9.5"

  cloud {
    organization = "talus-sre-challenge"
    workspaces {
      name = "talus-sre-challenge"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.37.0"
    }
  }
}
