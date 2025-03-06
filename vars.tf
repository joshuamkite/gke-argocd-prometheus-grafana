variable "bucket" {
  description = "The name of the bucket to store the terraform state file."
  type = object({
    name   = string
    prefix = string
  })
}

variable "default_labels" {
  description = "Default labels to apply to resources"
  type        = map(string)
  default     = {}
}

# Removed GPU-related variables:
# default_node_pool_accelerator_count
# default_node_pool_accelerator_type
# default_node_pool_gpu_driver_version
# default_node_pool_gpu_sharing_strategy
# default_node_pool_max_shared_clients_per_gpu

variable "default_node_pool_auto_repair" {
  description = "Enable auto repair for the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_auto_upgrade" {
  description = "Enable auto upgrade for the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_disk_size_gb" {
  description = "Disk size for the default node pool in GB"
  type        = number
  default     = 100
}

variable "default_node_pool_disk_type" {
  description = "Disk type for the default node pool"
  type        = string
  default     = "pd-standard"
}

# Removed redundant boolean variables:
# default_node_pool_enable_gcfs
# default_node_pool_enable_gvnic

variable "default_node_pool_image_type" {
  description = "Image type for the default node pool"
  type        = string
  default     = "COS_CONTAINERD"
}

variable "default_node_pool_initial_node_count" {
  description = "Initial node count for the default node pool"
  type        = number
  default     = 80
}

variable "default_node_pool_labels" {
  description = "Labels for the default node pool"
  type        = map(any)
  default = {
    default-node-pool = true
  }
}

variable "default_node_pool_local_ssd_count" {
  description = "Local SSD count for the default node pool"
  type        = number
  default     = 0
}

variable "default_node_pool_locations" {
  description = "Locations for the default node pool"
  type        = string
  default     = "us-central1-b,us-central1-c"
}

variable "default_node_pool_logging_variant" {
  description = "Logging variant for the default node pool"
  type        = string
  default     = "DEFAULT"
}

variable "default_node_pool_machine_type" {
  description = "Machine type for the default node pool"
  type        = string
  default     = "e2-medium"
}

variable "default_node_pool_max_count" {
  description = "Maximum count for the default node pool"
  type        = number
  default     = 100
}

variable "default_node_pool_metadata" {
  description = "Metadata for the default node pool"
  type        = map(any)
  default = {
    node-pool-metadata-custom-value = "my-node-pool"
  }
}

variable "default_node_pool_min_count" {
  description = "Minimum count for the default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_name" {
  description = "The name of the default node pool"
  type        = string
  default     = "default-node-pool"
}

# Removed redundant boolean variables:
# default_node_pool_preemptible
# default_node_pool_spot

# Removed taints variable since we're using an empty list
# default_node_pool_taints

variable "default_node_pool_tags" {
  description = "Tags for the default node pool"
  type        = list(string)
  default = [
    "default-node-pool",
  ]
}

# Removed redundant boolean variables since we're using defaults:
# dns_cache
# filestore_csi_driver
# http_load_balancing
# network_policy

variable "gke_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gke-test-1"
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

variable "ip_range_pods" {
  description = "The IP range for GKE pods"
  type        = string
  default     = "us-central1-01-gke-01-pods"
}

variable "ip_range_services" {
  description = "The IP range for GKE services"
  type        = string
  default     = "us-central1-01-gke-01-services"
}

variable "network" {
  description = "The VPC network to use"
  type        = string
  default     = "vpc-01"
}

variable "oauth_scopes" {
  description = "OAuth scopes for all node pools"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "<PROJECT ID>"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "service_account" {
  description = "Service account to use for the default node pool"
  type        = string
  default     = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
}

variable "subnetwork" {
  description = "The subnetwork to use"
  type        = string
  default     = "us-central1-01"
}

variable "zones" {
  description = "The zones where GKE nodes will be created"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-f"]
}
variable "http_load_balancing" {
  description = "Enable HTTP load balancing"
  type        = bool
  default     = true
}



