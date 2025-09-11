#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"
LOCATION="polandcentral"

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating AKS cluster..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --network-plugin azure \
    --load-balancer-sku standard \
    --generate-ssh-keys

echo "Configuring kubectl..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Cluster ready! Use './delete-aks-cluster.sh' to remove it when done."
