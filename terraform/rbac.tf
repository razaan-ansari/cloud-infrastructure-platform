# 0. Create the Namespace FIRST
resource "kubernetes_namespace" "chaos_mesh" {
  metadata {
    name = "chaos-mesh"
  }
}

# 1. Create the Service Account
resource "kubernetes_service_account" "chaos_admin" {
  # This tells Terraform: Wait for the namespace to be ready!
  depends_on = [kubernetes_namespace.chaos_mesh] 

  metadata {
    name      = "chaos-admin-sa"
    namespace = "chaos-mesh"
  }
}

# 2. Bind it to the 'cluster-admin' role
resource "kubernetes_cluster_role_binding" "chaos_admin_binding" {
  metadata {
    name = "chaos-admin-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" 
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.chaos_admin.metadata[0].name
    namespace = "chaos-mesh"
  }
}