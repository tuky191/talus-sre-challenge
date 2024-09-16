variable "google_credentials" {
  type        = string
  description = "Credentials to access Google Cloud Platform."
  default     = ""
}

variable "google_project" {
  type        = string
  description = "The unique identifier for the project within Google Cloud Platform."
  default     = "talus-sre-challenge"
}

variable "google_region" {
  type        = string
  description = "The Google Cloud Platform region where the resources will be deployed."
  default     = "us-east5"
}

variable "env" {
  type        = string
  description = "Environment variable"
  default     = "develop"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-svc"
}

variable "pat_token" {
  description = "GitHub Container Registry Personal Access Token"
  type        = string
  default     = ""
}

variable "registry_username" {
  description = "Username for the Docker registry"
  type        = string
  default     = "tuky191"
}

variable "registry_email" {
  description = "Email for the Docker registry"
  type        = string
  default     = "turxaala@gmail.com"
}

variable "grafana_admin_password" {
  description = "Admin password for grafana"
  type        = string
  default     = ""
}

variable "backend_image" {
  description = "Image for backend app"
  type        = string
  default     = ""
}
