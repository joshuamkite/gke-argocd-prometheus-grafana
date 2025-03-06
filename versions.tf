provider "google" {
  project        = var.project_id
  region         = var.region
  default_labels = var.default_labels
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=6.24.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.36.0"
    }
  }
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
