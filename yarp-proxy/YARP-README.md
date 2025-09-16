# YARP Reverse Proxy for AKS

This project uses Microsoft's YARP (Yet Another Reverse Proxy) for ingress traffic management in Azure Kubernetes Service (AKS).

## What is YARP?

YARP is a high-performance, customizable reverse proxy built on ASP.NET Core. It provides:
- High performance and low latency
- Dynamic configuration updates
- Built-in health checks
- Load balancing
- Easy integration with .NET applications
- Extensive monitoring and observability

## Architecture

```
Internet → Azure Load Balancer → YARP Proxy Service → Backend Apps
                                      ↓
                               ┌─────────────┐
                               │ YARP Proxy  │
                               │ (2 replicas)│
                               └─────────────┘
                                      ↓
                           ┌─────────┬─────────┐
                           ▼         ▼
                    ┌─────────┐ ┌─────────┐
                    │  App1   │ │  App2   │
                    │Service  │ │Service  │
                    └─────────┘ └─────────┘
```

## Route Configuration

The YARP proxy routes traffic as follows:
- `/app1/*` → `simple-app1-cluster-ip` service
- `/app2/*` → `simple-app2-cluster-ip` service

## Files Structure

```
├── yarp-proxy/
│   ├── Program.cs              # YARP application entry point
│   ├── YarpProxy.csproj       # .NET project file
│   ├── appsettings.json       # YARP configuration
│   └── Dockerfile             # Container image definition
├── 3-1-namespace.yaml          # YARP namespace
├── 3-2-configmap.yaml          # YARP configuration ConfigMap
├── 3-3-deployment.yaml         # YARP deployment
├── 3-4-service.yaml            # YARP LoadBalancer service
├── 3-install-yarp-proxy.sh     # YARP installation script
└── YARP-README.md             # This file
```

## Deployment Steps

### 1. Create AKS cluster
```bash
bash 1-create-aks-cluster.sh
```

### 2. Deploy sample applications
```bash
bash 2-deploy-sample-apps.sh
```

### 3. Install YARP reverse proxy
```bash
bash 3-install-yarp-proxy.sh
```

## Testing

Once deployed, you can test the proxy:

```bash
# Get external IP
kubectl get svc yarp-proxy-service -n yarp-proxy

# Test applications (replace <EXTERNAL-IP> with actual IP)
curl http://<EXTERNAL-IP>/app1
curl http://<EXTERNAL-IP>/app2
curl http://<EXTERNAL-IP>/app1/test
curl http://<EXTERNAL-IP>/app2/anything

# Test health endpoint
curl http://<EXTERNAL-IP>/health
```

## Monitoring

### Check YARP proxy status
```bash
kubectl get pods -n yarp-proxy
kubectl get svc -n yarp-proxy
```

### View YARP logs
```bash
kubectl logs -n yarp-proxy deployment/yarp-proxy -f
```

### View configuration
```bash
kubectl get configmap yarp-config -n yarp-proxy -o yaml
```

## Configuration

The YARP configuration is stored in a ConfigMap (`yarp-config`) and includes:

- **Routes**: Define path matching and transformations
- **Clusters**: Define backend services and destinations
- **Health Checks**: Active health monitoring of backend services
- **Load Balancing**: Automatic distribution across healthy backends

## Advantages of YARP

1. **Native .NET Integration**: Better performance for .NET workloads
2. **Simplified Configuration**: Configuration via JSON instead of labels/annotations
3. **Built-in Health Checks**: Comprehensive health monitoring out of the box
4. **Azure Integration**: Better integration with Azure services and monitoring
5. **Customization**: Easy to extend with custom middleware
6. **Performance**: Optimized for high-throughput scenarios

## Troubleshooting

### YARP pod not starting
```bash
kubectl describe pod -n yarp-proxy -l app=yarp-proxy
kubectl logs -n yarp-proxy -l app=yarp-proxy
```

### Configuration issues
```bash
kubectl get configmap yarp-config -n yarp-proxy -o yaml
```

### Backend connectivity issues
```bash
# Check if backend services are running
kubectl get svc
kubectl get pods

# Test backend services directly
kubectl port-forward svc/simple-app1-cluster-ip 8081:80
curl http://localhost:8081
```

### External IP not assigned
```bash
# Check load balancer service
kubectl get svc yarp-proxy-service -n yarp-proxy
kubectl describe svc yarp-proxy-service -n yarp-proxy
```

## Configuration Updates

To update YARP configuration:

1. Edit the ConfigMap in `3-2-configmap.yaml`
2. Apply the changes: `kubectl apply -f 3-2-configmap.yaml`
3. Restart YARP pods: `kubectl rollout restart deployment/yarp-proxy -n yarp-proxy`

The configuration will be automatically reloaded without downtime.