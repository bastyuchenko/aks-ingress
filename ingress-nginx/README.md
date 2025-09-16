# AKS Ingress Testing Environment with ingress-nginx

This repository contains a complete solution for AKS cluster management with ingress-nginx controller implementation. The setup includes Python-based sample applications that handle path-based routing natively without requiring middleware complexity.

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
   bash 1-create-aks-cluster.sh
   ```

3. **Deploy ingress-nginx Controller**:
   ```bash
   bash 2-install-ingress-controller.sh
   ```

4. **Deploy Sample Applications**:
   ```bash
   bash 3-deploy-sample-apps.sh
   ```

5. **Apply Ingress Configuration**:
   ```bash
   bash 4-apply-ingress-config.sh
   ```

6. **Check Cluster Status**:
   ```bash
   bash check-cluster-status.sh
   ```

7. **Delete AKS Cluster** (to save costs):
   ```bash
   bash delete-aks-cluster.sh
   ```

## Configuration

The scripts use hardcoded values optimized for cost and testing:

- **Resource Group**: `aks-ingress`
- **Cluster Name**: `aks-ingress-cluster`
- **Location**: `polandcentral`
- **Node Count**: `1` (minimal for testing)
- **Network Plugin**: `azure` (Azure CNI for advanced networking)
- **Load Balancer**: Standard (supports round-robin)
- **Ingress Controller**: ingress-nginx (NGINX-based ingress controller)
- **Sample Apps**: Python-based apps with native path handling

## Architecture Overview

### ingress-nginx Controller
- **External LoadBalancer**: Provides public access via Azure Load Balancer
- **Path-based Routing**: Routes `/app1` and `/app2` to respective services
- **SSL Termination**: Handles HTTPS termination and redirects
- **Health Checks**: Built-in readiness and liveness probes

### Sample Applications
- **Simple Python Apps**: Custom HTTP servers that handle any path natively
- **No Middleware Required**: Apps respond to full request paths (e.g., `/app1`, `/app1/test`)
- **Resource Efficient**: Lightweight containers with 64Mi memory requests

## Cost Optimization Features

- **Single node**: Minimal cost with 1 node only
- **Poland Central region**: Optimal location for your use case
- **Azure CNI**: Advanced networking for Ingress testing
- **Complete deletion**: Scripts delete all resources to avoid charges

## Estimated Costs

- **Running cluster**: ~$20-40/month (single node)
- **Stopped cluster**: $0 (when using delete script)

## Scripts Overview

### 1-create-aks-cluster.sh
- Creates resource group `aks-ingress`
- Creates AKS cluster with 1 node
- Automatically configures kubectl
- Ready in ~10-15 minutes

### 2-install-ingress-controller.sh
- Deploys ingress-nginx controller via Helm
- Configures external LoadBalancer service
- Enables SSL termination and HTTPS redirect
- Sets up health monitoring

### 3-deploy-sample-apps.sh
- Deploys Python-based sample applications
- Creates ConfigMaps with application code
- Establishes services for internal routing
- Apps handle any request path natively

### 4-apply-ingress-config.sh
- Applies clean Kubernetes Ingress resources
- No middleware complexity required
- Sets up path-based routing (/app1, /app2)
- Provides testing commands and URLs

### check-cluster-status.sh
- Verifies cluster exists
- Gets kubectl credentials
- Shows node and service status

### delete-aks-cluster.sh
- Asks for confirmation
- Deletes entire resource group
- Runs in background for fast completion

## Usage for Path-based Ingress Testing

Once your cluster is fully deployed, you'll have a working ingress-nginx setup:

### Testing URLs
After running all scripts, you'll get an external IP address (e.g., `134.112.11.73`):

```bash
# Test path-based routing
curl http://YOUR-EXTERNAL-IP/app1
curl http://YOUR-EXTERNAL-IP/app2

# Test sub-paths (apps handle them natively)
curl http://YOUR-EXTERNAL-IP/app1/test
curl http://YOUR-EXTERNAL-IP/app2/anything
```

### Browser Access
1. Visit `http://YOUR-EXTERNAL-IP/app1` in your browser
2. Navigate between `/app1` and `/app2` endpoints

### ingress-nginx Controller Status
```bash
# Check ingress-nginx controller status
kubectl get pods -n ingress-nginx

# Port-forward to access nginx status
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Visit http://localhost:8080 for basic status
```

### Key Features Demonstrated
- **Path-based routing**: Different apps served based on URL path
- **Native path handling**: No middleware required for path manipulation
- **SSL termination**: Handled by ingress-nginx controller
- **Service discovery**: Kubernetes-native ingress configuration

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

# Check ingress status
kubectl get ingress

# View ingress-nginx service and external IP
kubectl get svc -n ingress-nginx

# Check application pods
kubectl get pods

# View ingress-nginx controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f
```

## Security Notes

- SSH keys are automatically generated
- Managed identity is used for authentication
- Standard Azure security practices applied

## Contributing

This repository demonstrates a complete AKS ingress solution. Key components:

### File Structure
- `3-simple-apps.yaml`: Python application deployments and services
- `4-simple-ingress.yaml`: Clean Kubernetes Ingress configuration
- Numbered scripts follow logical deployment sequence

### Customization Options
- **Scaling**: Modify replica counts in deployment YAML
- **Domains**: Replace external IP with custom domain names
- **SSL**: Configure Let's Encrypt for production certificates
- **Monitoring**: Add Prometheus/Grafana for advanced monitoring

### Why This Architecture?
- **Simplicity**: No complex middleware or path manipulation
- **Cost Effective**: Single-node cluster optimized for learning
- **Production Ready**: ingress-nginx patterns scale to production use
- **Educational**: Demonstrates modern Kubernetes ingress patterns

Remember to test changes in a separate environment first!
