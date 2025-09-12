#!/bin/bash

echo "Applying ingress configurations..."

# Apply the ingress rules
kubectl apply -f ingress-examples.yaml

echo "Waiting for ingress to be ready..."
sleep 10

echo "Getting ingress details..."
kubectl get ingress

echo "Getting Traefik ingress controller external IP..."
EXTERNAL_IP=$(kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$EXTERNAL_IP" ]; then
    echo ""
    echo "================================================"
    echo "Traefik Ingress setup complete!"
    echo "External IP: $EXTERNAL_IP"
    echo "================================================"
    echo ""
    echo "To test your applications:"
    echo "1. Host-based routing:"
    echo "   curl -H 'Host: app1.local' http://$EXTERNAL_IP"
    echo "   curl -H 'Host: app2.local' http://$EXTERNAL_IP"
    echo ""
    echo "2. Path-based routing:"
    echo "   curl http://$EXTERNAL_IP/app1"
    echo "   curl http://$EXTERNAL_IP/app2"
    echo ""
    echo "3. Access Traefik Dashboard:"
    echo "   kubectl port-forward -n traefik svc/traefik 8080:8080"
    echo "   Then visit: http://localhost:8080"
    echo ""
    echo "4. Or add to /etc/hosts (Linux/Mac) or C:\\Windows\\System32\\drivers\\etc\\hosts (Windows):"
    echo "   $EXTERNAL_IP app1.local"
    echo "   $EXTERNAL_IP app2.local"
    echo ""
    echo "Then visit: http://app1.local or http://app2.local in your browser"
else
    echo "External IP not yet assigned. Check again with:"
    echo "kubectl get svc traefik -n traefik"
fi