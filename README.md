# GKE ArgoCD Prometheus Grafana

This repository contains Terraform configurations and Kubernetes manifests to set up a basic small-scale Google Kubernetes Engine (GKE) cluster with ArgoCD for GitOps-based deployments. It includes monitoring components including Prometheus and Grafana.

- [GKE ArgoCD Prometheus Grafana](#gke-argocd-prometheus-grafana)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [1. Deployment](#1-deployment)
    - [2. Connect to GKE cluster](#2-connect-to-gke-cluster)
    - [3. Install ArgoCD](#3-install-argocd)
    - [4. Access ArgoCD](#4-access-argocd)
    - [5. Deploy Monitoring Stack via ApplicationSet](#5-deploy-monitoring-stack-via-applicationset)
  - [Accessing Monitoring Tools](#accessing-monitoring-tools)
    - [Prometheus](#prometheus)
    - [Grafana](#grafana)
  - [Cleanup](#cleanup)
    - [Delete ApplicationSet (optional)](#delete-applicationset-optional)
    - [Delete GKE Cluster](#delete-gke-cluster)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Overview

This project provisions:

1. A GKE cluster in Google Cloud using Terraform
2. ArgoCD for GitOps-based deployments
3. Monitoring stack including:
   - Prometheus (kube-prometheus-stack)
   - Grafana with pre-configured dashboards
   
Note: Metrics Server is already included in GKE clusters by default.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= 1.5.0)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional)
- Google Cloud Project with appropriate permissions
- GKE auth plugin (`gcloud components install gke-gcloud-auth-plugin`)

## Getting Started

**N.B. My `terraform.tfvars` (not committed to public GitHub repo) is like:**

```terraform
# Cluster basics
project_id = "xxxxxxxxxxxxxx"

# Cluster basics
gke_cluster_name = "study-cluster"
region           = "europe-west2"
zones            = ["europe-west2-a"] # Single zone for simplicity

# Network settings
network           = "vpc-01"
subnetwork        = "europe-west2-01"
ip_range_pods     = "europe-west2-01-gke-01-pods"
ip_range_services = "europe-west2-01-gke-01-services"

# Node pool configuration - single modest node
default_node_pool_name         = "study-pool"
default_node_pool_machine_type = "e2-standard-2"  # 2 vCPUs, 8GB memory
default_node_pool_locations    = "europe-west2-a" # Single zone
default_node_pool_min_count    = 1
default_node_pool_max_count    = 1  # Fixed at 1 node
default_node_pool_disk_size_gb = 50 # Reduced disk size
# We'll use the dynamically created service account instead
# service_account is now referenced from the google_service_account resource
default_node_pool_initial_node_count = 1

# Simplified labels and metadata
default_node_pool_labels = {
  purpose   = "study"
  temporary = "true"
}

default_node_pool_metadata = {
  node-pool-metadata-custom-value = "study-pool"
}

# Simple tag
default_node_pool_tags = [
  "study-cluster",
]

bucket = {
  name   = "XXXXXXXXXXXX"
  prefix = "gke/study-cluster"
}

```

### 1. Deployment

Deploy cluster with Terraform

### 2. Connect to GKE cluster

(if GKE auth plugin not already installed)
```bash
gcloud components install gke-gcloud-auth-plugin
```

```bash
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials study-cluster --region europe-west2
```

Verify the connection:

```bash
kubectl get nodes
```

### 3. Install ArgoCD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

### 4. Access ArgoCD

Get the initial admin password (**change this for production!**):

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Set up port forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

(Optional) Access ArgoCD UI at: http://localhost:8080

Login via CLI:

```bash
argocd login localhost:8080 --username admin --password <your-password> --insecure --grpc-web
```

### 5. Deploy Monitoring Stack via ApplicationSet

Apply the ApplicationSet manifest:

```bash
kubectl apply -f monitoring-apps.yaml
```

This will deploy:
- Prometheus (kube-prometheus-stack)
- Grafana with pre-configured Prometheus datasource and Kubernetes dashboard

Note: Metrics Server is already included in GKE clusters by default.

## Accessing Monitoring Tools

### Prometheus

Set up port forwarding:

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
```

Access Prometheus at: http://localhost:9090

### Grafana

Get Grafana admin password:

```bash
# Username: admin
# Password:
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```

Set up port forwarding:

```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```

Access Grafana at: http://localhost:3000 (Username: `admin`)

## Cleanup

### Delete ApplicationSet (optional)

```bash
argocd appset delete monitoring-apps
```

### Delete GKE Cluster

```bash
tofu destroy
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=6.24.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.24.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.gke_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_iam_member.gke_sa_permissions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.compute_api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.container_api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.iam_api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.gke_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the bucket to store the terraform state file. | <pre>object({<br/>    name   = string<br/>    prefix = string<br/>  })</pre> | n/a | yes |
| <a name="input_default_labels"></a> [default\_labels](#input\_default\_labels) | Default labels to apply to resources | `map(string)` | `{}` | no |
| <a name="input_default_node_pool_auto_repair"></a> [default\_node\_pool\_auto\_repair](#input\_default\_node\_pool\_auto\_repair) | Enable auto repair for the default node pool | `bool` | `true` | no |
| <a name="input_default_node_pool_auto_upgrade"></a> [default\_node\_pool\_auto\_upgrade](#input\_default\_node\_pool\_auto\_upgrade) | Enable auto upgrade for the default node pool | `bool` | `true` | no |
| <a name="input_default_node_pool_disk_size_gb"></a> [default\_node\_pool\_disk\_size\_gb](#input\_default\_node\_pool\_disk\_size\_gb) | Disk size for the default node pool in GB | `number` | `100` | no |
| <a name="input_default_node_pool_disk_type"></a> [default\_node\_pool\_disk\_type](#input\_default\_node\_pool\_disk\_type) | Disk type for the default node pool | `string` | `"pd-standard"` | no |
| <a name="input_default_node_pool_image_type"></a> [default\_node\_pool\_image\_type](#input\_default\_node\_pool\_image\_type) | Image type for the default node pool | `string` | `"COS_CONTAINERD"` | no |
| <a name="input_default_node_pool_initial_node_count"></a> [default\_node\_pool\_initial\_node\_count](#input\_default\_node\_pool\_initial\_node\_count) | Initial node count for the default node pool | `number` | `80` | no |
| <a name="input_default_node_pool_labels"></a> [default\_node\_pool\_labels](#input\_default\_node\_pool\_labels) | Labels for the default node pool | `map(any)` | <pre>{<br/>  "default-node-pool": true<br/>}</pre> | no |
| <a name="input_default_node_pool_local_ssd_count"></a> [default\_node\_pool\_local\_ssd\_count](#input\_default\_node\_pool\_local\_ssd\_count) | Local SSD count for the default node pool | `number` | `0` | no |
| <a name="input_default_node_pool_locations"></a> [default\_node\_pool\_locations](#input\_default\_node\_pool\_locations) | Locations for the default node pool | `string` | `"us-central1-b,us-central1-c"` | no |
| <a name="input_default_node_pool_logging_variant"></a> [default\_node\_pool\_logging\_variant](#input\_default\_node\_pool\_logging\_variant) | Logging variant for the default node pool | `string` | `"DEFAULT"` | no |
| <a name="input_default_node_pool_machine_type"></a> [default\_node\_pool\_machine\_type](#input\_default\_node\_pool\_machine\_type) | Machine type for the default node pool | `string` | `"e2-medium"` | no |
| <a name="input_default_node_pool_max_count"></a> [default\_node\_pool\_max\_count](#input\_default\_node\_pool\_max\_count) | Maximum count for the default node pool | `number` | `100` | no |
| <a name="input_default_node_pool_metadata"></a> [default\_node\_pool\_metadata](#input\_default\_node\_pool\_metadata) | Metadata for the default node pool | `map(any)` | <pre>{<br/>  "node-pool-metadata-custom-value": "my-node-pool"<br/>}</pre> | no |
| <a name="input_default_node_pool_min_count"></a> [default\_node\_pool\_min\_count](#input\_default\_node\_pool\_min\_count) | Minimum count for the default node pool | `number` | `1` | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | The name of the default node pool | `string` | `"default-node-pool"` | no |
| <a name="input_default_node_pool_tags"></a> [default\_node\_pool\_tags](#input\_default\_node\_pool\_tags) | Tags for the default node pool | `list(string)` | <pre>[<br/>  "default-node-pool"<br/>]</pre> | no |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | The name of the GKE cluster | `string` | `"gke-test-1"` | no |
| <a name="input_horizontal_pod_autoscaling"></a> [horizontal\_pod\_autoscaling](#input\_horizontal\_pod\_autoscaling) | Enable horizontal pod autoscaling | `bool` | `true` | no |
| <a name="input_http_load_balancing"></a> [http\_load\_balancing](#input\_http\_load\_balancing) | Enable HTTP load balancing | `bool` | `true` | no |
| <a name="input_ip_range_pods"></a> [ip\_range\_pods](#input\_ip\_range\_pods) | The IP range for GKE pods | `string` | `"us-central1-01-gke-01-pods"` | no |
| <a name="input_ip_range_services"></a> [ip\_range\_services](#input\_ip\_range\_services) | The IP range for GKE services | `string` | `"us-central1-01-gke-01-services"` | no |
| <a name="input_network"></a> [network](#input\_network) | The VPC network to use | `string` | `"vpc-01"` | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | OAuth scopes for all node pools | `list(string)` | <pre>[<br/>  "https://www.googleapis.com/auth/logging.write",<br/>  "https://www.googleapis.com/auth/monitoring"<br/>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID | `string` | `"<PROJECT ID>"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy resources | `string` | `"us-central1"` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service account to use for the default node pool | `string` | `"project-service-account@<PROJECT ID>.iam.gserviceaccount.com"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The subnetwork to use | `string` | `"us-central1-01"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The zones where GKE nodes will be created | `list(string)` | <pre>[<br/>  "us-central1-a",<br/>  "us-central1-b",<br/>  "us-central1-f"<br/>]</pre> | no |

## Outputs

No outputs.
