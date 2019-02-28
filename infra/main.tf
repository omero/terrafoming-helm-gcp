# configure providers

provider "google" {
  region  = "${var.region}"
}

provider "kubernetes" {
  host = "https://${module.gke.endpoint}"
  username               = "${var.gke_master_user}"
  password               = "${var.gke_master_pass}"
  client_certificate     = "${base64decode(module.gke.client_certificate)}"
  client_key             = "${base64decode(module.gke.client_key)}"
  cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
}

provider "helm" {
  version = "~> 0.7.0"

  kubernetes {
    host     = "https://${module.gke.endpoint}"
    username               = "${var.gke_master_user}"
    password               = "${var.gke_master_pass}"
    client_certificate     = "${base64decode(module.gke.client_certificate)}"
    client_key             = "${base64decode(module.gke.client_key)}"
    cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
  }

  service_account = "${module.k8s.service_account}"
  namespace       = "${module.k8s.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.12.1"  
}

module "vpc" {
  source = "./backend/vpc"
}

module "subnet" {
  source      = "./backend/subnet"
  region      = "${var.region}"
  vpc_name    = "${module.vpc.vpc_name}"
  subnet_cidr = "${var.subnet_cidr}"
}

module "ip" {
  source      = "./backend/ip"
}

module "firewall" {
  source        = "./backend/firewall"
  vpc_name       = "${module.vpc.vpc_name}"
  ip_cidr_range = "${module.subnet.ip_cidr_range}"
}

module "gke" {
  source                = "./gke"
  region                = "${var.region}"
  gke_num_nodes         = "${var.gke_num_nodes}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_name           = "${module.subnet.subnet_name}"
  gke_master_user       = "${var.gke_master_user}"
  gke_master_pass       = "${var.gke_master_pass}"
  gke_node_machine_type = "${var.gke_node_machine_type}"
  gke_label             = "${var.gke_label}"
}

module "k8s" {
  source                  = "./k8s"
  reserved_ip             = "${module.ip.ip_reserved}"
}