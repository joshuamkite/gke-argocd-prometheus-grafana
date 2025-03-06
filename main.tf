# Enable required GCP APIs
resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"

  disable_dependent_services = false
  disable_on_destroy         = false
}









# Create VPC network
resource "google_compute_network" "vpc_network" {
  depends_on = [
    google_project_service.compute_api,
  ]
  name                    = var.network
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create subnet for GKE
resource "google_compute_subnetwork" "gke_subnet" {
  name          = var.subnetwork
  region        = var.region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/20" # Primary IP range for nodes
  project       = var.project_id

  # Secondary IP ranges for pods and services
  secondary_ip_range {
    range_name    = var.ip_range_pods
    ip_cidr_range = "10.16.0.0/14" # Pod IP range
  }

  secondary_ip_range {
    range_name    = var.ip_range_services
    ip_cidr_range = "10.20.0.0/20" # Service IP range
  }
}

# Create service account for GKE nodes
resource "google_service_account" "gke_service_account" {
  depends_on = [
    google_project_service.iam_api,
  ]
  account_id   = "gke-study-sa"
  display_name = "GKE Study Cluster Service Account"
  project      = var.project_id
}

# Grant required permissions to the service account
resource "google_project_iam_member" "gke_sa_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

module "gke" {

  depends_on = [
    google_project_service.container_api,
    google_compute_subnetwork.gke_subnet,
    google_service_account.gke_service_account,
    google_project_iam_member.gke_sa_permissions,
  ]

  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = var.gke_cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = google_compute_network.vpc_network.name
  subnetwork                 = google_compute_subnetwork.gke_subnet.name
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling

  node_pools = [
    {
      name               = var.default_node_pool_name
      machine_type       = var.default_node_pool_machine_type
      node_locations     = var.default_node_pool_locations
      min_count          = var.default_node_pool_min_count
      max_count          = var.default_node_pool_max_count
      local_ssd_count    = var.default_node_pool_local_ssd_count
      disk_size_gb       = var.default_node_pool_disk_size_gb
      disk_type          = var.default_node_pool_disk_type
      image_type         = var.default_node_pool_image_type
      logging_variant    = var.default_node_pool_logging_variant
      auto_repair        = var.default_node_pool_auto_repair
      auto_upgrade       = var.default_node_pool_auto_upgrade
      service_account    = google_service_account.gke_service_account.email
      initial_node_count = var.default_node_pool_initial_node_count
    },
  ]

  node_pools_oauth_scopes = {
    all               = var.oauth_scopes
    default-node-pool = []
  }

  node_pools_labels = {
    all               = {}
    default-node-pool = var.default_node_pool_labels
  }

  node_pools_metadata = {
    all               = {}
    default-node-pool = var.default_node_pool_metadata
  }

  node_pools_taints = {
    all               = []
    default-node-pool = []
  }

  node_pools_tags = {
    all               = []
    default-node-pool = var.default_node_pool_tags
  }
}
