#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"

echo "Checking cluster status..."

if az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME &> /dev/null; then
    echo "✓ Cluster exists and is running"
    echo "Getting kubectl context..."
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
    echo "Nodes:"
    kubectl get nodes
    echo ""
    echo "Ingress Controller Status:"
    kubectl get pods -n ingress-nginx 2>/dev/null || echo "ingress-nginx not installed"
    echo ""
    echo "Services:"
    kubectl get svc -n ingress-nginx 2>/dev/null || echo "No ingress-nginx services found"
else
    echo "✗ Cluster not found. Run ./1-create-aks-cluster.sh to create it."
fi
