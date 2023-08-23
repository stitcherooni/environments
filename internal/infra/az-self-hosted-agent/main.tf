#Create Namespace for Self-Hosted Agent
resource "kubernetes_namespace" "internal_build_agent" {
  metadata {
    name = "internal-build-agent"
  }
}