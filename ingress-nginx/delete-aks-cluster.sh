#!/bin/bash

RESOURCE_GROUP="aks-ingress"

echo "Deleting AKS cluster and resource group..."
echo "This will remove all resources in the resource group."
read -p "Continue? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

az group delete --name $RESOURCE_GROUP --yes --no-wait
echo "Deletion initiated. Resources will be removed in a few minutes."
