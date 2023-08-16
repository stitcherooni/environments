## Short guide how to use Azure Bastion:

**Prerequisites:**

- You’ll need the Azure CLI installed at the OS level.
- An Azure subscription with access to Azure SQL and Azure Bastion services.
- An Azure Virtual Machine deployed in your Azure subscription.

**Authenticate**

Open a PowerShell terminal on your machine and login to Azure.

```Azure CLI
az login
```

Check you are in the right subscription. (This is your “current context”.)

```Azure CLI
az account show
```

If not then change subscription.

```Azure CLI
az account set --subscription "<subscription ID>"
```

**Open a tunnel through Azure Bastion to a target virtual machine or resource**

```Azure CLI
az network bastion tunnel --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --resource-port 22 --port 2222
```

After that you can create ssh tunel to any service in side network (e.g cosmosdb)

```CMD
ssh -L 20255:$your_db_name.mongo.cosmos.azure.com:10255 -p 2222 ssh_user@localhost
```

Or to the some resource(in testing):

```Azure CLI
az network bastion tunnel --resource-group MyResourceGroup --name MyBastionHost --target-resource-id "$(az mysql flexible-server show --resource-group test --name db-test --query id --output tsv)" --resource-port 3306 --port 33306

mysql -u db_admin -p -h 127.0.0.1:33306
```

**SSH to a virtual machine using Tunneling from Azure Bastion**

SSH to virtual machine using Azure Bastion using ssh key file.

```Azure CLI
az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type ssh-key --username xyz --ssh-key C:/filepath/sshkey.pem
```

SSH to virtual machine using Azure Bastion using AAD.

```Azure CLI
az network bastion ssh --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId --auth-type AAD
```

**RDP to target Virtual Machine using Tunneling from Azure Bastion**

```Azure CLI
az network bastion rdp --name MyBastionHost --resource-group MyResourceGroup --target-resource-id vmResourceId
```

If you tunneling to a web service you may open browser with url `https://localhost:2222`, or if you made tunnel to SSH server, connect with `ssh -p 2222 localhost` command

## ############################################# ##
## Accessing AKS API via Bastion host SSH tunnel ##
## Prerequisites ##

- A private AKS cluster or a cluster with a whitelisting network policy that prevents k8s API from being publicly accessible.
- Bastion host that has access to the respective AKS API.
- Access to Bastion host via SSH.
- Permission to access the respective AKS cluster.

### SSH config example

```shell
Host aks1
    User            %SSH_USERNAME%
    HostName        %BASTION_HOST_IP%
    Port            443
    IdentityFile    ~/.ssh/id_rsa_azure_bastion
    LocalForward    11111 you.aks.cluster.name01.fqdn:443

Host aks2
    User            %SSH_USERNAME%
    HostName        %BASTION_HOST_IP%
    Port            22
    IdentityFile    ~/.ssh/id_rsa_azure_bastion
    LocalForward    11112 you.aks.cluster.name02.fqdn:443
```
### kube/config snippet example

```yaml
---
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: %YOUR_CLUSTER_CA_DATA%
    server: https://localhost:11111     # replace you.aks.cluster.fqdn URL with localhost name.
  name: you-aks-cluster-name01
- cluster:
    certificate-authority-data: %YOUR_CLUSTER_CA_DATA%
    server: https://localhost:11112     # replace you.aks.cluster.fqdn URL with localhost name.
  name: you-aks-cluster-name02
contexts:
# ... SKIPPED ...
```

### Connection to a AKS API via SSH tunnel

1. Create a tunnel that will drop after 300 seconds of inactivity: `ssh -f aks1 sleep 300`
2. Switch your kubectl context to a respective AKS cluser: `kubectl config use-context you-aks-cluster-name01`
3. Check that everything works as expected: `kubectl get nodes -o wide`

# External documentations

- [A Visual Guide to SSH Tunnels: Local and Remote Port Forwarding](https://iximiuz.com/en/posts/ssh-tunnels/)
                                                                   (https://blog.knoldus.com/how-to-access-the-private-cluster-using-bastion-server-on-azure-portal/)