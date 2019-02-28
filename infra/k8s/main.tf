# Configure tiller to install releases with helm
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "terraform-tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "terraform-tiller"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind = "ServiceAccount"
    name = "terraform-tiller"

    api_group = ""
    namespace = "kube-system"
  }
}
# Install neccesary helm charts
resource "helm_repository" "keel_repo" {
  name = "keel-charts"
  url  = "https://charts.keel.sh"
  depends_on = ["kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}
resource "helm_release" "keel" {
  name = "keel"
  repository = "${helm_repository.keel_repo.metadata.0.name}"
  chart = "keel-charts/keel"
  namespace = "kube-system"

  set {
      name = "helmProvider.enabled"
      value = "true"
  }

  set {
      name = "rbac.enabled"
      value = "true"
  }

  depends_on = ["kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller"]
}
resource "helm_release" "nginx_ingress" {
  name      = "ingress"
  chart     = "stable/nginx-ingress"
  wait      = false

  set {
      name  = "controller.service.loadBalancerIP"
      value = "${var.reserved_ip}"
  }

  set {
      name = "rbac.create"
      value = "true"
  }

  set {
      name = "defaultBackend.enabled"
      value = "false"
  }
  depends_on = ["helm_release.keel"]
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  version   = "v0.5.2"

  set {
      name  = "ingressShim.defaultIssuerName"
      value = "letsencrypt-prod"
  }

  set {
      name = "ingressShim.defaultIssuerKind"
      value = "ClusterIssuer"
  }
  depends_on = ["helm_release.nginx_ingress"]
}

# resource "helm_release" "cat-app" {
#     name      = "cat-app"
#     chart     = "../helm/cat-app"

#     depends_on = ["helm_release.cert_manager"]
# }