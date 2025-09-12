#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"

echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Adding Traefik Helm repository..."
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

echo "Installing Traefik Ingress Controller..."
helm install traefik traefik/traefik \
    --create-namespace \
    --namespace traefik \
    --set service.type=LoadBalancer \
    --set ports.web.redirectTo=websecure \
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
echo "kubectl port-forward -n traefik svc/traefik 8080:8080"
echo "Then visit: http://localhost:8080"
echo ""
echo "The external IP will be assigned shortly. Check with:"
echo "kubectl get svc -n traefik"