# LoadBalancer and YARP Proxy Traffic Flow

This document explains how the LoadBalancer service works with the YARP proxy deployment in this AKS ingress setup.

## Traffic Flow Overview

```
Internet/External Client
         ↓
Azure Load Balancer (External IP)
         ↓
LoadBalancer Service (yarp-proxy-service)
         ↓
YARP Proxy Pods (2 replicas)
         ↓
Backend Applications (app1/app2)
```

## Detailed Flow Explanation

### 1. LoadBalancer Service Configuration

The `3-4-service.yaml` creates a LoadBalancer service with:
- **Type**: `LoadBalancer` - This provisions an external Azure Load Balancer
- **Port**: 80 (external) → 80 (internal)
- **Selector**: `app: yarp-proxy` - This is the key connection point

```yaml
apiVersion: v1
kind: Service
metadata:
  name: yarp-proxy-service
  namespace: yarp-proxy
  labels:
    app: yarp-proxy
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
      name: http
  selector:
    app: yarp-proxy  # This matches pods with this label
```

### 2. Service-to-Pod Selection

The LoadBalancer service uses the selector `app: yarp-proxy` to identify target pods. This matches the labels in the deployment:

```yaml
# In 3-3-deployment.yaml
spec:
  template:
    metadata:
      labels:
        app: yarp-proxy  # This matches the service selector
```

### 3. Load Distribution

- The deployment has `replicas: 2`, creating 2 YARP proxy pods
- The LoadBalancer service automatically distributes incoming requests between these 2 pods
- Kubernetes uses round-robin load balancing by default
- Only healthy pods (passing readiness probes) receive traffic

### 4. YARP Proxy Routing

When a request reaches a YARP proxy pod, it uses the configuration from the ConfigMap (`3-2-configmap.yaml`):

#### Route Configuration:
- **`/app1/*`** requests → routed to `simple-app1-cluster-ip.default.svc.cluster.local`
- **`/app2/*`** requests → routed to `simple-app2-cluster-ip.default.svc.cluster.local`
- Path prefixes are removed (e.g., `/app1/hello` becomes `/hello`)

#### Route Rules:
```json
"app1-route": {
  "ClusterId": "app1-cluster",
  "Match": {
    "Path": "/app1/{**catch-all}"
  },
  "Transforms": [
    {
      "PathRemovePrefix": "/app1"
    }
  ]
}
```

### 5. Complete Request Flow Example

Here's what happens when a client makes a request:

```
1. Client requests: http://<external-ip>/app1/api/users

2. Azure Load Balancer receives the request
   ↓
3. LoadBalancer Service (yarp-proxy-service) on port 80
   ↓
4. Service selects one of 2 available yarp-proxy pods
   ↓
5. YARP proxy processes the request:
   - Matches "/app1/{**catch-all}" route
   - Removes "/app1" prefix from path
   - Forwards to: http://simple-app1-cluster-ip.default.svc.cluster.local/api/users
   ↓
6. Backend app1 processes the request and returns response
   ↓
7. Response flows back through the same path to the client
```

### 6. Health Checks & Reliability

The system has multiple layers of health checking:

#### Service Level
- LoadBalancer only routes traffic to pods that pass Kubernetes readiness probes
- Unhealthy pods are automatically removed from the service endpoints

#### Pod Level (Kubernetes Probes)
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
```

#### YARP Level (Backend Health Checks)
```json
"HealthCheck": {
  "Active": {
    "Enabled": true,
    "Interval": "00:00:30",
    "Timeout": "00:00:05",
    "Policy": "ConsecutiveFailures",
    "Path": "/"
  }
}
```

### 7. Key Architecture Benefits

- **External Access**: LoadBalancer provides a stable external IP address
- **High Availability**: 2 YARP proxy replicas provide redundancy
- **Load Distribution**: Traffic is automatically distributed across proxy instances
- **Centralized Routing**: YARP handles all routing logic and path transformations
- **Health Monitoring**: Multiple layers of health checking ensure reliability
- **Scalability**: Easy to scale by increasing replica count
- **Configuration Management**: Routing rules managed via ConfigMap

### 8. Network Namespaces

- **YARP Proxy**: Runs in `yarp-proxy` namespace
- **Backend Apps**: Run in `default` namespace
- **Service Discovery**: Uses Kubernetes DNS (`.svc.cluster.local`)

### 9. Resource Management

Each YARP proxy pod has resource limits:
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

This ensures predictable performance and prevents resource starvation.

## Summary

The LoadBalancer service acts as the entry point that makes the internal YARP proxy accessible from the internet. It provides external connectivity, load balancing across multiple proxy instances, and integrates seamlessly with Kubernetes service discovery and health checking mechanisms. YARP then handles sophisticated routing and load balancing to backend applications based on URL paths.