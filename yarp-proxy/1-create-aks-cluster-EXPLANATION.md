# AKS Automatically Created Resources Explanation

When you create an Azure Kubernetes Service (AKS) cluster, Azure automatically provisions several supporting resources to enable the cluster's functionality. Here's an explanation of each resource created by your script:

## Network Security Group (NSG)
**Resource:** `aks-agentpool-XXXXXXXX-nsg`

**Purpose:**
- Acts as a virtual firewall for the AKS node pool
- Controls inbound and outbound network traffic to/from the worker nodes
- Contains default security rules that allow:
  - Kubernetes API server communication
  - Inter-node communication within the cluster
  - Load balancer health probes
  - SSH access (if enabled)
- Automatically managed by Azure to ensure proper cluster networking

## Managed Identity
**Resource:** `aks-ingress-cluster-agentpool`

**Purpose:**
- Provides the AKS cluster with an Azure AD identity
- Eliminates the need for service principals and credential management
- Allows the cluster to authenticate with other Azure services like:
  - Azure Container Registry (ACR)
  - Azure Key Vault
  - Azure Storage
  - Virtual Network resources
- Automatically rotates credentials for enhanced security
- Enables role-based access control (RBAC) integration

## Virtual Machine Scale Set (VMSS)
**Resource:** `aks-nodepool1-XXXXXXX-vmss`

**Purpose:**
- Manages the worker nodes (VMs) that run your Kubernetes workloads
- Provides automatic scaling capabilities (horizontal pod autoscaler)
- Ensures high availability by distributing nodes across availability zones
- Handles node lifecycle management including:
  - Node provisioning and deprovisioning
  - OS updates and patches
  - Node replacement in case of failures
- Supports different VM sizes and node configurations

## Virtual Network (VNet)
**Resource:** `aks-vnet-XXXXXX`

**Purpose:**
- Provides isolated network environment for the AKS cluster
- Enables Azure CNI networking (since you specified `--network-plugin azure`)
- Allows pods to receive IP addresses directly from the VNet address space
- Facilitates communication between:
  - Pods within the cluster
  - Pods and Azure services
  - On-premises networks (via VPN/ExpressRoute)
- Enables network policies and advanced networking features

## Public IP Address
**Resource:** `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX`

**Purpose:**
- Provides external connectivity for the AKS cluster
- Used by the load balancer to expose services to the internet
- Enables inbound traffic routing to Kubernetes services of type `LoadBalancer`
- Allows external access to ingress controllers
- Static IP that persists across load balancer recreations

## Load Balancer
**Resource:** `kubernetes`

**Purpose:**
- Distributes incoming network traffic across multiple nodes
- Provides high availability for exposed services
- Automatically created when you create services of type `LoadBalancer`
- Routes traffic from the public IP to the appropriate backend pods
- Performs health checks to ensure traffic only goes to healthy nodes
- Integrates with Azure's load balancing infrastructure for reliability

## Resource Management Notes

### Automatic Management
- All these resources are automatically managed by Azure
- They're created in a separate "node resource group" (usually named `MC_<resource-group>_<cluster-name>_<location>`)
- Azure handles their lifecycle, updates, and maintenance

### Cost Implications
- Each resource may incur costs based on usage and configuration
- VMSS nodes are the primary cost drivers
- Public IP and Load Balancer have minimal costs but should be considered

### Cleanup
- When you delete the AKS cluster, these resources are automatically removed
- Use your `delete-aks-cluster.sh` script to ensure proper cleanup and avoid unnecessary charges

## Next Steps for Ingress Setup

Since you're working on AKS ingress, you'll likely need to:
1. Install an ingress controller (like NGINX or Application Gateway)
2. Configure ingress resources to route traffic
3. Set up TLS certificates for HTTPS
4. Configure DNS routing to your services

The load balancer and public IP created here will work with your ingress controller to provide external access to your applications.

// ...existing code...

## Traffic Flow: Internet to Application

Here's how internet traffic flows through all the AKS resources to reach your application:

```
Internet Request
       ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AZURE CLOUD                                 │
│                                                                 │
│  1. Public IP Address                                          │
│     (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX)                    │
│     • Static external IP endpoint                              │
│     • First entry point from internet                         │
│                         ↓                                       │
│                                                                 │
│  2. Load Balancer (kubernetes)                                 │
│     • Receives traffic from Public IP                         │
│     • Performs health checks on backend nodes                 │
│     • Distributes load across healthy nodes                   │
│                         ↓                                       │
│                                                                 │
│  3. Network Security Group (aks-agentpool-XXXXXXXX-nsg)       │
│     • Firewall rules validation                               │
│     • Allows/denies traffic based on security rules           │
│     • Permits load balancer health probes                     │
│                         ↓                                       │
│                                                                 │
│  4. Virtual Network (aks-vnet-XXXXXX)                       │
│     • Internal network routing                                │
│     • Azure CNI network plugin handles IP allocation          │
│     • Routes traffic to appropriate subnet                    │
│                         ↓                                       │
│                                                                 │
│  5. Virtual Machine Scale Set (aks-nodepool1-XXXXXXX-vmss)   │
│     • Contains the worker nodes (VMs)                         │
│     • Load balancer selects healthy node                      │
│     • Traffic reaches specific VM instance                    │
│                         ↓                                       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              KUBERNETES CLUSTER                             │ │
│  │                                                             │ │
│  │  6. Ingress Controller (e.g., NGINX)                      │ │
│  │     • Receives traffic on node                             │ │
│  │     • Routes based on hostname/path rules                  │ │
│  │     • SSL/TLS termination (if configured)                 │ │
│  │                         ↓                                   │ │
│  │                                                             │ │
│  │  7. Kubernetes Service                                     │ │
│  │     • Internal load balancing to pods                     │ │
│  │     • Service discovery and routing                       │ │
│  │                         ↓                                   │ │
│  │                                                             │ │
│  │  8. Application Pod                                        │ │
│  │     • Your containerized application                      │ │
│  │     • Processes the request                               │ │
│  │     • Returns response                                     │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Detailed Flow Steps

### Step 1: Internet Request Arrives
- User makes HTTP/HTTPS request to your domain
- DNS resolves to the Public IP address
- Request hits Azure's edge network

### Step 2: Public IP Processing
- **Resource**: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX`
- Static IP receives the request
- Forwards to associated Load Balancer

### Step 3: Load Balancer Distribution
- **Resource**: `kubernetes` Load Balancer
- Performs health checks on backend nodes
- Selects healthy node using configured algorithm (round-robin, etc.)
- Forwards request to selected node

### Step 4: Security Validation
- **Resource**: `aks-agentpool-XXXXXXXX-nsg`
- Network Security Group evaluates request against rules
- Allows traffic that matches permitted patterns
- Blocks malicious or unauthorized traffic

### Step 5: Virtual Network Routing
- **Resource**: `aks-vnet-XXXXXX`
- Azure CNI handles internal network routing
- Routes traffic to appropriate subnet where target node resides
- Maintains network isolation and security

### Step 6: Node Processing
- **Resource**: `aks-nodepool1-XXXXXXX-vmss`
- Traffic reaches specific VM in the scale set
- Node's network interface receives the packet
- Forwards to Kubernetes networking layer

### Step 7: Ingress Controller (If Configured)
- Ingress controller pod receives traffic
- Evaluates ingress rules (hostname, path, etc.)
- Performs SSL termination if configured
- Routes to appropriate Kubernetes service

### Step 8: Service Load Balancing
- Kubernetes Service receives request
- Internal load balancing across backend pods
- Forwards to healthy application pod

### Step 9: Application Processing
- Your application pod processes the request
- Generates response
- Response follows reverse path back to client

## Authentication Flow (Managed Identity)
- **Resource**: `aks-ingress-cluster-agentpool`
- Throughout this process, the cluster uses its Managed Identity to:
  - Authenticate with Azure Container Registry for image pulls
  - Access Azure Key Vault for secrets
  - Communicate with other Azure services
  - Maintain cluster operations

## High Availability Considerations

### Multiple Paths
- Load balancer can route to any healthy node
- If one node fails, traffic automatically routes to others
- Scale set ensures replacement nodes are created

### Health Monitoring
- Load balancer continuously monitors node health
- Unhealthy nodes are removed from rotation
- Health probes validate end-to-end connectivity

### Fault Tolerance
- Azure manages infrastructure failures
- Kubernetes handles application-level failures
- Automatic failover at multiple layers

This flow demonstrates how all the automatically created resources work together to provide a robust, scalable, and highly available path from the internet to your applications running in AKS.

// ...existing code...


# Where Traefik pods run on?

To see where Traefik pods are running across your nodes, use this command:

This will show you which specific worker nodes the Traefik pods are scheduled on.

Key points about pod placement:

* Traefik pods run on worker nodes only - not on the master node
* The master node typically has taints that prevent regular workloads from being scheduled there
* With 3 worker nodes, Traefik pods could be on any combination of them depending on:
  * Your deployment's replica count
  * Node resources and availability
  * Any node selectors or affinity rules configured  
  
The -o wide flag will show you the NODE column so you can see exactly which of your 3 worker nodes are currently hosting the Traefik pods.