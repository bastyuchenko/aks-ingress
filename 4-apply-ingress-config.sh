#!/bin/bash

echo "Applying simple ingress configuration..."

# Apply the simple ingress rules (no middleware needed)
kubectl apply -f 4-simple-ingress.yaml

echo "Waiting for ingress to be ready..."
sleep 10

echo "Getting ingress details..."
kubectl get ingress

echo "Getting Traefik ingress controller external IP..."
EXTERNAL_IP=$(kubectl get ingress traefic-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$EXTERNAL_IP" ]; then
    echo ""
    echo "================================================"
    echo "Simple Path-based Ingress setup complete!"
    echo "External IP: $EXTERNAL_IP"
    echo "================================================"
    echo ""
    echo "To test your applications (no middleware needed!):"
    echo ""
    echo "Path-based routing:"
    echo "   curl -k https://$EXTERNAL_IP/app1"
    echo "   curl -k https://$EXTERNAL_IP/app2"
    echo "   curl -k https://$EXTERNAL_IP/app1/test"
    echo "   curl -k https://$EXTERNAL_IP/app2/anything"
    echo ""
    echo "Browser access (accept SSL certificate):"
    echo "   https://$EXTERNAL_IP/app1"
    echo "   https://$EXTERNAL_IP/app2"
    echo ""
    echo "Access Traefik Dashboard:"
    echo "   kubectl port-forward svc/traefik 8080:8080"
    echo "   Then visit: http://localhost:8080"
    echo ""
    echo "Note: These simple apps handle any path natively,"
    echo "      so no middleware configuration is required!"
else
    echo "External IP not yet assigned. Check again with:"
    echo "kubectl get svc traefik"
fi