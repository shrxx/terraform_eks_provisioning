provider "kubernetes" {
  host                   = var.k8s_cluster_endpoint
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
  token                  = var.k8s_cluster_token
}
resource "kubernetes_namespace" "web" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "web" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.web.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyWebApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyWebApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "web" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.web.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.web.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}