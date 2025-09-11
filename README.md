# AKS Ingress Testing Environment

This repository contains simplified scripts to create and manage an AKS cluster for testing custom Ingress controllers. The scripts are optimized for Visual Studio Professional $50/month subscriptions.

## Prerequisites

1. **Azure CLI**: Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. **kubectl**: Usually installed with Azure CLI, or install separately
3. **Azure Subscription**: Visual Studio Professional subscription with appropriate permissions

## Quick Start

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Create AKS Cluster**:
   ```bash
   ./create-aks-cluster.sh
   ```

3. **Check Cluster Status**:
   ```bash
   ./check-cluster-status.sh
   ```

4. **Delete AKS Cluster** (to save costs):
   ```bash
   ./delete-aks-cluster.sh
   ```

## Configuration

The scripts use hardcoded values optimized for cost and testing:

- **Resource Group**: `aks-ingress`
- **Cluster Name**: `aks-ingress-cluster`
- **Location**: `polandcentral`
- **Node Count**: `1` (minimal for testing)
- **Network Plugin**: `azure` (Azure CNI for advanced networking)
- **Load Balancer**: Standard (supports round-robin)

## Cost Optimization Features

- **Single node**: Minimal cost with 1 node only
- **Poland Central region**: Optimal location for your use case
- **Azure CNI**: Advanced networking for Ingress testing
- **Complete deletion**: Scripts delete all resources to avoid charges

## Estimated Costs

- **Running cluster**: ~$20-40/month (single node)
- **Stopped cluster**: $0 (when using delete script)

## Scripts Overview

### create-aks-cluster.sh

Simple cluster creation:
- Creates resource group `aks-ingress`
- Creates AKS cluster with 1 node
- Automatically configures kubectl
- Ready in ~10-15 minutes

### delete-aks-cluster.sh

Quick cleanup:
- Asks for confirmation
- Deletes entire resource group
- Runs in background for fast completion

### check-cluster-status.sh

Status check:
- Verifies cluster exists
- Gets kubectl credentials
- Shows node status

## Usage for Ingress Controller Testing

Once your cluster is created, you can use it for testing custom Ingress controllers:

1. **Deploy your custom Ingress controller**
2. **Create test applications**
3. **Configure Ingress rules**
4. **Test routing and load balancing**

Example commands after cluster creation:
```bash
# Check cluster status
kubectl get nodes
kubectl get namespaces

# Create a test deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=ClusterIP

# Your custom Ingress controller testing goes here
```

## Troubleshooting

### Common Issues

1. **Authentication errors**: Run `az login`
2. **Permission errors**: Ensure Contributor access to subscription
3. **kubectl context issues**: Run `./check-cluster-status.sh`

### Useful Commands

```bash
# Check current Azure subscription
az account show

# List all resource groups
az group list --output table

# Reset kubectl context
az aks get-credentials --resource-group aks-ingress --name aks-ingress-cluster
```

## Security Notes

- SSH keys are automatically generated
- Managed identity is used for authentication
- Standard Azure security practices applied

## Contributing

The scripts are intentionally simple. Modify them as needed:
- Change resource names by editing script variables
- Add additional Azure services
- Include monitoring or logging features

Remember to test changes in a separate environment first!
