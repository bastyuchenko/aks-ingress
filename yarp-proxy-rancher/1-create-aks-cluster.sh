#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"
LOCATION="polandcentral"
ACR_NAME="aksingressacr"

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating AKS cluster..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --network-plugin azure \
    --enable-managed-identity \
    --generate-ssh-keys

echo "Creating Azure Container Registry..."
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --location $LOCATION \
    --admin-enabled true

echo "Attaching ACR to AKS cluster..."
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --attach-acr $ACR_NAME

echo "Created ACR: $ACR_NAME"

echo "Configuring kubectl..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Cluster ready! Use './delete-aks-cluster.sh' to remove it when done."