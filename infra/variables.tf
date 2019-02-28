# GCP variables

variable "region" {
  default     = "us-central1"
  description = "Region of resources"
}

variable "name" {
  default = {
    prod = "prod"
    dev  = "dev"
  }

  description = "Name for worspaces"
}

# Network variables

variable "subnet_cidr" {
  default = {
    prod = "10.10.0.0/24"
    dev  = "10.240.0.0/24"
  }

  description = "Subnet range"
}

# GKE variables

variable "gke_num_nodes" {
  default = {
    prod = 3
    dev  = 2
  }

  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_master_user" {
  default     = "k8s_admin"
  description = "Username to authenticate with the k8s master"
}

variable "gke_master_pass" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_node_machine_type" {
  default     = "n1-standard-1"
  description = "Machine type of GKE nodes"
}

variable gke_label {
  default = {
    prod = "prod"
    dev  = "dev"
  }

  description = "label"
}