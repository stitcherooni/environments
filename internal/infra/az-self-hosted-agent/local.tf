locals {
  #Main
  tenant_id       = "ff9085aa-053a-4b01-8817-effac5fdfdce"
  subscription_id = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"

  secret = {
    "azp-token" = {
      type = "Opaque"
      metadata = {
        secret_name = "azp-token"
        namespace   = "internal-build-agent"
      }
      secret_data = {
        AZP_TOKEN = data.azurerm_key_vault_secret.azp_token.value
      }
    }
  }

  #Azure Build Agent Deployment
  deployment_conf = {
    "internal_build_agent" = {
      metadata = {
        name      = "agent"
        namespace = kubernetes_namespace.internal_build_agent.id
        labels = {
          "app.kubernetes.io/name"     = "azure-pipelines-agent"
          "app.kubernetes.io/instance" = "agent"
        }
      }
      spec = {
        replicas = "1"
        selector = {
          match_labels = {
            "app.kubernetes.io/name"     = "azure-pipelines-agent"
            "app.kubernetes.io/instance" = "agent"
          }
        }
        template = {
          metadata = {
            labels = {
              "app.kubernetes.io/name"     = "azure-pipelines-agent"
              "app.kubernetes.io/instance" = "agent"
            }
          }
          spec = {
            container = {
              name              = "azure-pipelines-agent"
              image             = "azcentralcr.azurecr.io/az-self-hosted-agent:arm64"
              image_pull_policy = "Always"
              resources = {
                limits = {
                  #cpu    = "0.5"
                  memory = "6Gi"
                }
                requests = {
                  #cpu    = "250m"
                  #memory = "50Mi"
                }      
              }
              env = [
                {
                  name = "AZP_AGENT_NAME"
                  value_from = {
                    field_ref = {
                      api_version = "v1"
                      field_path  = "metadata.name"
                    }
                  }
                },
                {
                  name  = "AZP_URL"
                  value = "https://dev.azure.com/ptaevents"
                },
                {
                  name  = "AZP_POOL"
                  value = "internal-agent"
                },
                {
                  name = "AZP_TOKEN"
                  value_from = {
                    secret_key_ref = {
                      name = local.secret.azp-token.metadata.secret_name
                      key  = "AZP_TOKEN"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    }
  }

  #KEDA config (Internal Build Agent Scaling)
  internal_build_agent_scaling = {
    name        = "agent-scaler"
    namespace   = kubernetes_namespace.internal_build_agent.id
    labels_name = local.deployment_conf.internal_build_agent.metadata.name

    min_replica_count = "1"
    max_replica_count = "3"
    polling_interval = 20

    azp_pool_id = 10
    azp_url  = local.deployment_conf.internal_build_agent.spec.template.spec.container.env.1.name
    azp_token = local.deployment_conf.internal_build_agent.spec.template.spec.container.env.3.name
  }
}
