#!/bin/bash

RESOURCE_GROUP="aks-ingress"
CLUSTER_NAME="aks-ingress-cluster"
ACR_NAME="aksingressacr"

echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin --overwrite-existing

echo "Building YARP proxy Docker image..."

cd yarp-proxy
nerdctl build -t yarp-proxy:latest .

echo "Loading Docker image into AKS cluster..."

echo "Found ACR: $ACR_NAME - pushing image..."
nerdctl tag yarp-proxy:latest $ACR_NAME.azurecr.io/yarp-proxy:latest
echo "Getting ACR access token..."
ACR_TOKEN=$(az acr login -n $ACR_NAME --expose-token --output tsv --query accessToken)
echo "$ACR_TOKEN" | nerdctl login $ACR_NAME.azurecr.io -u 00000000-0000-0000-0000-000000000000 --password-stdin
nerdctl push $ACR_NAME.azurecr.io/yarp-proxy:latest
cd ..
echo "Image successfully pushed to ACR: $ACR_NAME.azurecr.io/yarp-proxy:latest"

echo "Deploying YARP Reverse Proxy..."
kubectl apply -f 3-1-namespace.yaml
kubectl apply -f 3-2-configmap.yaml
kubectl apply -f 3-3-deployment.yaml
kubectl apply -f 3-4-service.yaml

echo "Waiting for YARP proxy to be ready..."
kubectl wait --namespace yarp-proxy \
    --for=condition=ready pod \
    --selector=app=yarp-proxy \
    --timeout=120s

echo "Getting external IP address..."
kubectl get service yarp-proxy-service --namespace yarp-proxy

echo "Getting YARP proxy external IP..."
EXTERNAL_IP=$(kubectl get service yarp-proxy-service -n yarp-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$EXTERNAL_IP" ]; then
    echo ""
    echo "================================================"
    echo "YARP Reverse Proxy deployed successfully!"
    echo "External IP: $EXTERNAL_IP"
    echo "================================================"
    echo ""
    echo "Features enabled:"
    echo "✅ Path-based routing to /app1 and /app2"
    echo "✅ Health checks for backend services"
    echo "✅ Load balancer service for external access"
    echo "✅ High availability with 2 replicas"
    echo ""
    echo "To test your applications:"
    echo ""
    echo "Path-based routing:"
    echo "   curl http://$EXTERNAL_IP/app1"
    echo "   curl http://$EXTERNAL_IP/app2"
    echo "   curl http://$EXTERNAL_IP/app1/test"
    echo "   curl http://$EXTERNAL_IP/app2/anything"
    echo ""
    echo "Browser access:"
    echo "   http://$EXTERNAL_IP/app1"
    echo "   http://$EXTERNAL_IP/app2"
    echo ""
    echo "Health check endpoint:"
    echo "   curl http://$EXTERNAL_IP/health"
    echo ""
    echo "The YARP proxy routes traffic as follows:"
    echo "/app1/* -> simple-app1-cluster-ip service"
    echo "/app2/* -> simple-app2-cluster-ip service"
    echo ""
    echo "YARP proxy logs:"
    echo "   kubectl logs -n yarp-proxy deployment/yarp-proxy -f"
    echo ""
    echo "YARP proxy configuration:"
    echo "   kubectl get configmap yarp-config -n yarp-proxy -o yaml"
    echo ""
    echo "The YARP proxy automatically:"
    echo "• Routes /app1/* to simple-app1-cluster-ip"
    echo "• Routes /app2/* to simple-app2-cluster-ip"
    echo "• Performs health checks on backend services"
    echo "• Provides load balancing across replicas"
else
    echo ""
    echo "================================================"
    echo "YARP Reverse Proxy deployed successfully!"
    echo "================================================"
    echo ""
    echo "Features enabled:"
    echo "✅ Path-based routing to /app1 and /app2"
    echo "✅ Health checks for backend services"
    echo "✅ Load balancer service for external access"
    echo "✅ High availability with 2 replicas"
    echo ""
    echo "The YARP proxy routes traffic as follows:"
    echo "/app1/* -> simple-app1-cluster-ip service"
    echo "/app2/* -> simple-app2-cluster-ip service"
    echo ""
    echo "To check YARP proxy status:"
    echo "kubectl get pods -n yarp-proxy"
    echo "kubectl logs -n yarp-proxy deployment/yarp-proxy"
    echo ""
    echo "External IP not yet assigned. Check again with:"
    echo "kubectl get svc yarp-proxy-service -n yarp-proxy"
    echo ""
    echo "Once external IP is assigned, test with:"
    echo "kubectl get svc yarp-proxy-service -n yarp-proxy"
fi