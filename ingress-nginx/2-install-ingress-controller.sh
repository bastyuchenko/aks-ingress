#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"

echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Adding ingress-nginx Helm repository..."
# Helm equivalent
# Apt equivalent would be:
# sudo add-apt-repository <repository>
# sudo apt update

# The helm repo add and helm repo update commands operate on the local machine where you run the commands, 
# not specifically on any Kubernetes node. Here's the breakdown:

# Local Helm Client
#   Location: The machine where you execute these commands (could be your laptop, a bastion host, 
#       or wherever you have helm CLI installed)
#   Storage: Helm stores repository information locally in your Helm configuration directory:
#       Linux/macOS: ~/.config/helm/repositories.yaml or ~/.cache/helm/repository/
#       Windows: %APPDATA%\helm\repositories.yaml
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Installing ingress-nginx Controller..."
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --create-namespace \
    --namespace ingress-nginx \
    --values 2-ingress-nginx-values.yaml

echo "Waiting for ingress-nginx to be ready..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=ingress-nginx \
    --timeout=120s

echo "Getting external IP address..."
kubectl get service ingress-nginx-controller --namespace ingress-nginx

echo ""
echo "================================================"
echo "ingress-nginx Controller deployed successfully!"
echo "================================================"
echo ""
echo "Features enabled:"
echo "✅ LoadBalancer service type"
echo "✅ External traffic access"
echo "✅ Forwarded headers support"
echo "✅ Health monitoring"
echo ""
echo "To check controller status:"
echo "kubectl get pods -n ingress-nginx"
echo ""
echo "The external IP will be assigned shortly. Check with:"
echo "kubectl get svc -n ingress-nginx"
echo ""
echo "To view controller logs:"
echo "kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f"