#!/bin/bash

echo "Applying simple ingress configuration..."

# Apply the simple ingress rules (no middleware needed)
kubectl apply -f 4-simple-ingress.yaml

echo "Waiting for ingress to be ready..."
sleep 10

echo "Getting ingress details..."
kubectl get ingress

echo "Getting ingress-nginx controller external IP..."
EXTERNAL_IP=$(kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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
    echo "   curl http://$EXTERNAL_IP/app1"
    echo "   curl http://$EXTERNAL_IP/app2"
    echo "   curl http://$EXTERNAL_IP/app1/test"
    echo "   curl http://$EXTERNAL_IP/app2/anything"
    echo ""
    echo "Browser access:"
    echo "   http://$EXTERNAL_IP/app1"
    echo "   http://$EXTERNAL_IP/app2"
    echo ""
    echo "Check ingress-nginx controller status:"
    echo "   kubectl get pods -n ingress-nginx"
    echo "   kubectl logs -n ingress-nginx deployment/ingress-nginx-controller"
    echo ""
    echo "Note: These simple apps handle any path natively,"
    echo "      so no middleware configuration is required!"
else
    echo "External IP not yet assigned. Check again with:"
    echo "kubectl get svc -n ingress-nginx"
fi