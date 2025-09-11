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
else
    echo "✗ Cluster not found. Run ./create-aks-cluster.sh to create it."
fi
