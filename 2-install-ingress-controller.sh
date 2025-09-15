#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"

echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Adding Traefik Helm repository..."
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
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

echo "Installing Traefik Ingress Controller..."
helm install traefik traefik/traefik \
    --create-namespace \
    --namespace traefik \
    --set service.type=LoadBalancer \
    --set ports.web.redirections.entryPoint.to=websecure \
    --set ports.web.redirections.entryPoint.scheme=https \
    --set ports.websecure.tls.enabled=true \
    --set ingressRoute.dashboard.enabled=true \
    --set api.dashboard=true \
    --set api.insecure=true

echo "Waiting for Traefik to be ready..."
kubectl wait --namespace traefik \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=traefik \
    --timeout=120s

echo "Getting external IP address..."
kubectl get service traefik --namespace traefik

echo ""
echo "================================================"
echo "Traefik Ingress Controller deployed successfully!"
echo "================================================"
echo ""
echo "Features enabled:"
echo "✅ HTTP to HTTPS redirect"
echo "✅ TLS/SSL support"
echo "✅ Dashboard enabled"
echo "✅ API access enabled"
echo ""
echo "To access Traefik dashboard:"
echo "kubectl port-forward -n traefik deployment/traefik 8080:8080"
echo "Then visit: http://localhost:8080/dashboard/"
echo ""
echo "The external IP will be assigned shortly. Check with:"
echo "kubectl get svc -n traefik"
echo ""
echo "To stop port forwarding, press Ctrl+C in the terminal where port-forward is running"