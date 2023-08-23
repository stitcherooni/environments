locals {
  secret = {
    "secret1" = {
      type = "kubernetes.io/basic-auth"
      metadata = {
        secret_name = "basic-auth1"
        namespace   = "default"
      }
      secret_data = {
        username = "admin1"
        password = "P4ssw0rd1"
      }
    }
  }

  deployment_conf = {
    "internal_build_agent" = {
      metadata = {
        name      = agent
        namespace = kubernetes_namespace.internal_build_agent.name
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
                image             = "azcentralcr.azurecr.io/az-self-hosted-agent:latest"
                image_pull_policy = "Always"

                env = [
                  {
                    name = "AZP_AGENT_NAME"
                    value_from = {
                      field_ref = {
                        api_version = "v1"
                        field_path  = local.deployment_conf.internal_build_agent
                      }
                    }
                  },
                  {
                    name = "AZP_URL"
                    value = "https://dev.azure.com/ptaevents"
                  },
                  {
                    name = "AZP_POOL"
                    value = "internal-agent"
                  },
                  {
                    name = "AZP_POOL"
                    value_from = {
                      secret_key_ref = {
                        name = "azdevops"
                        key = "AZP_TOKEN"
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
  }
}
