resource "google_service_account" "default" {
  account_id   = "${var.google_project}-sa"
  display_name = "${var.google_project}-sa"
}



resource "google_project_iam_member" "cluster_service_account-nodeService_account" {
  project = var.google_project
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.default.member
  depends_on = [
    google_service_account.default
  ]
}

resource "google_project_iam_member" "cluster_service_account-metric_writer" {
  project = var.google_project
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.default.member
  depends_on = [
    google_service_account.default
  ]
}

resource "google_project_iam_member" "cluster_service_account-resourceMetadata-writer" {
  project = var.google_project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = google_service_account.default.member
  depends_on = [
    google_service_account.default
  ]
}

resource "google_project_iam_member" "cluster_service_account-gcr" {
  project = var.google_project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.default.email}"
  depends_on = [
    google_service_account.default
  ]
}

resource "google_project_iam_member" "cluster_service_account-artifact-registry" {
  project = var.google_project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.default.email}"
  depends_on = [
    google_service_account.default
  ]
}

resource "google_service_account" "backend_sa" {
  account_id   = "${var.google_project}-backend-sa"
  display_name = "${var.google_project}-backend-sa"
}

resource "google_project_iam_binding" "storage_object_user" {
  project = var.google_project
  role    = "roles/storage.objectUser"

  members = [
    "serviceAccount:${google_service_account.backend_sa.email}"
  ]

  depends_on = [
    kubernetes_service_account.backend_sa
  ]
}

resource "google_project_iam_binding" "workload_identity_user" {
  project = var.google_project
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[backend/backend-service-account]"
  ]
}

resource "kubernetes_service_account" "backend_sa" {
  metadata {
    name      = "backend-service-account"
    namespace = "backend"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.backend_sa.email
    }
  }
  depends_on = [
    google_service_account.backend_sa
  ]
}

data "google_client_openid_userinfo" "me" {}

resource "kubernetes_cluster_role_binding" "cluster_admin_binding" {
  metadata {
    name = "cluster-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = data.google_client_openid_userinfo.me.email
    api_group = "rbac.authorization.k8s.io"
  }
}
