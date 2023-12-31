# Create Namespace for Self-Hosted Agent
resource "kubernetes_namespace" "internal_build_agent" {
  metadata {
    name = "internal-build-agent"
  }
}

resource "kubernetes_manifest" "build_agent_scaling_auth" {
  manifest = yamldecode(<<EOF
  apiVersion: keda.sh/v1alpha1
  kind: TriggerAuthentication
  metadata:
    name: ${local.secret.azp-token.metadata.secret_name}
    namespace: ${lookup(local.internal_build_agent_scaling, "namespace", "default")}
  spec:
    secretTargetRef:
      - parameter: personalAccessToken
        name: ${local.secret.azp-token.metadata.secret_name}
        key: AZP_TOKEN
  EOF
  )
}

# Azure Build agent scaling (KEDA)
resource "kubernetes_manifest" "scale_podinfo" {

  manifest = yamldecode(<<EOF
  apiVersion: keda.sh/v1alpha1
  kind: ScaledObject
  metadata:
    name: ${lookup(local.internal_build_agent_scaling, "name", "agent-scaler")}
    namespace: ${lookup(local.internal_build_agent_scaling, "namespace", "default")}   
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: ${local.deployment_conf.internal_build_agent.metadata.name}
    pollingInterval: ${lookup(local.internal_build_agent_scaling, "polling_interval", 30)}
    cooldownPeriod: 150
    minReplicaCount: ${lookup(local.internal_build_agent_scaling, "min_replica_count", 1)}
    maxReplicaCount: ${lookup(local.internal_build_agent_scaling, "max_replica_count", 2)}
    triggers:
    - type: azure-pipelines
      metadata:
        poolID: ${lookup(local.internal_build_agent_scaling, "azp_pool_id")}
        organizationURLFromEnv: ${lookup(local.internal_build_agent_scaling, "azp_url")}
        personalAccessTokenFromEnv: ${lookup(local.internal_build_agent_scaling, "azp_token")}
  EOF
  )
}