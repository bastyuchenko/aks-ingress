#!/bin/bash

echo "Deploying simple Python-based sample applications..."

# Deploy simple Python apps that handle any path natively
# These apps can respond to any URL path without requiring middleware
# Perfect for testing path-based ingress routing
kubectl apply -f 3-simple-apps.yaml

echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/simple-app1
kubectl rollout status deployment/simple-app2

echo "Simple applications deployed!"
echo "Services created:"
kubectl get svc | grep simple-app

echo "Pods status:"
kubectl get pods | grep simple-app

echo ""
echo "Simple applications are ready! These apps handle any path natively."
echo "No middleware configuration is needed for path-based routing."