#!/bin/bash

echo "Deploying sample applications..."

# Deploy sample app 1
kubectl create deployment app1 --image=nginx:latest
kubectl expose deployment app1 --port=80 --target-port=80

# Deploy sample app 2  
kubectl create deployment app2 --image=httpd:latest
kubectl expose deployment app2 --port=80 --target-port=80

echo "Sample applications deployed!"
echo "Services created:"
kubectl get svc

# Create a simple HTML page for app1
kubectl create configmap app1-html --from-literal=index.html='<h1>Welcome to App 1!</h1>'
kubectl patch deployment app1 -p '{"spec":{"template":{"spec":{"volumes":[{"name":"html","configMap":{"name":"app1-html"}}],"containers":[{"name":"nginx","volumeMounts":[{"name":"html","mountPath":"/usr/share/nginx/html"}]}]}}}}'

# Create a simple HTML page for app2
kubectl create configmap app2-html --from-literal=index.html='<h1>Welcome to App 2!</h1>'
kubectl patch deployment app2 -p '{"spec":{"template":{"spec":{"volumes":[{"name":"html","configMap":{"name":"app2-html"}}],"containers":[{"name":"httpd","volumeMounts":[{"name":"html","mountPath":"/usr/local/apache2/htdocs"}]}]}}}}'

echo "Sample applications configured with custom content!"