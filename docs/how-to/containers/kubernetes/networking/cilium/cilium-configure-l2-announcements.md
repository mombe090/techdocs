# How to Configure Cilium L2 Announcements on Talos Linux

**Goal**: Configure Cilium to announce LoadBalancer IPs on Layer 2 networks for external accessibility.

**Scenario**: You have a Talos Linux cluster with Cilium CNI and need LoadBalancer services accessible from outside the cluster without MetalLB or cloud provider integration.

**Time**: 20-30 minutes

**Prerequisites**:

- Talos Linux cluster (v1.x)
- Cilium installed as CNI (v1.16.0+)
- `kubectl` access to the cluster
- Helm 3 installed (recommended for upgrades)
- IP address pool available on your LAN

---

## Understanding the Configuration Approach

Cilium L2 announcements require three main components:

1. **LB-IPAM Configuration** - IP pool management
2. **L2 Announcements Enabled** - Feature flag activation
3. **L2 Announcement Policy** - Network interface and node selection

You can configure these using:

=== "Helm Values (Recommended)"

    **Pros**:

    - Version controlled
    - Easier to maintain
    - Reproducible deployments
    - Clear audit trail

    **Cons**:

    - Requires Helm knowledge
    - Full cluster upgrade needed

=== "kubectl Apply (Alternative)"

    **Pros**:

    - Quick changes
    - No cluster-wide upgrade
    - Good for testing

    **Cons**:

    - Configuration drift risk
    - Harder to track changes
    - Must manage RBAC separately

!!! tip "Best Practice"
Use Helm values for production environments. Use `kubectl apply` only for testing or temporary fixes.

---

## Method 1: Configure with Helm Values

### Step 1: Check Current Cilium Installation

First, verify Cilium is installed via Helm:

```bash
helm list -n kube-system
```

Expected output:

```
NAME    NAMESPACE       REVISION        UPDATED         STATUS          CHART
cilium  kube-system     1               2024-12-05      deployed        cilium-1.16.5
```

If Cilium wasn't installed via Helm, see [Migration Guide](#migrating-from-manual-installation).

### Step 2: Export Current Values

```bash
helm get values cilium -n kube-system > cilium-current-values.yaml
```

!!! warning "Talos-Specific Settings"
Don't modify these Talos-required settings:

    - `k8sServiceHost: localhost`
    - `k8sServicePort: "7445"` (KubePrism)
    - `cgroup.autoMount.enabled: false`
    - `cgroup.hostRoot: /sys/fs/cgroup`

### Step 3: Create Complete Helm Values

Create `cilium-values.yaml` with L2 support enabled:

```yaml
# Talos-specific Kubernetes API configuration
k8sServiceHost: localhost
k8sServicePort: "7445"

# Talos cgroup v2 configuration
cgroup:
  autoMount:
    enabled: false
  hostRoot: /sys/fs/cgroup

# IP Address Management (IPAM)
ipam:
  mode: kubernetes
  operator:
    clusterPoolIPv4PodCIDRList: ["10.244.0.0/16"] # (1)!

# LoadBalancer IP Address Management
l2announcements:
  enabled: true # (2)!
  leaseDuration: 120s
  leaseRenewDeadline: 60s
  leaseRetryPeriod: 1s

externalIPs:
  enabled: true

# Enable necessary features
ingressController:
  enabled: false
  loadbalancerMode: dedicated

# Gateway API support (optional)
gatewayAPI:
  enabled: false

# BGP Control Plane (if using BGP alongside L2)
bgpControlPlane:
  enabled: false

# Security and monitoring
hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true

operator:
  replicas: 1
  prometheus:
    enabled: true

prometheus:
  enabled: true

# Kubeproxy replacement
kubeProxyReplacement: true
```

1. Match your cluster's Pod CIDR
2. This enables L2 announcements feature

### Step 4: Create RBAC Permissions

Cilium needs RBAC permissions for leader election using leases.

Create `cilium-l2-rbac.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cilium-l2-announcement
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cilium-l2-announcement
  namespace: kube-system
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["create", "get", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cilium-l2-announcement
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cilium-l2-announcement
subjects:
  - kind: ServiceAccount
    name: cilium-l2-announcement
    namespace: kube-system
```

Apply RBAC:

```bash
kubectl apply -f cilium-l2-rbac.yaml
```

### Step 5: Upgrade Cilium with New Values

```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --values cilium-values.yaml \
  --version 1.16.5
```

!!! tip "Version Selection"
Check available versions: `helm search repo cilium/cilium --versions`

Wait for rollout:

```bash
kubectl rollout status daemonset/cilium -n kube-system
kubectl rollout status deployment/cilium-operator -n kube-system
```

### Step 6: Verify L2 Announcements Feature

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg status | grep -i l2
```

Expected output:

```
L2 Announcements:     Enabled
```

Also check operator logs:

```bash
kubectl logs -n kube-system deployment/cilium-operator | grep -i l2
```

Should see:

```
level=info msg="L2 announcements enabled"
```

---

## Method 2: Configure with IP Pools and Policies

### Step 1: Create IP Address Pool

Choose between **CiliumLoadBalancerIPPool** (newer, recommended) or **ConfigMap** (legacy).

=== "CiliumLoadBalancerIPPool (Recommended)"

    Create `lb-ip-pool.yaml`:

    ```yaml
    apiVersion: cilium.io/v2alpha1
    kind: CiliumLoadBalancerIPPool
    metadata:
      name: prod-pool
    spec:
      blocks:
        - cidr: "192.168.10.70/28"  # (1)!
      serviceSelector:
        matchExpressions:
          - key: io.kubernetes.service.namespace
            operator: In
            values:
              - default
              - monitoring
              - ingress
    ```

    1. Provides IPs: 192.168.10.64 - 192.168.10.79 (16 addresses, ~14 usable)

    Apply:

    ```bash
    kubectl apply -f lb-ip-pool.yaml
    ```

=== "ConfigMap (Legacy)"

    Create `lb-ip-pool-configmap.yaml`:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: bgp-config
      namespace: kube-system
    data:
      config.yaml: |
        address-pools:
          - name: default
            protocol: layer2
            addresses:
              - 192.168.10.70-192.168.10.90
    ```

    Apply:

    ```bash
    kubectl apply -f lb-ip-pool-configmap.yaml
    ```

    !!! warning "Deprecated Approach"
        ConfigMap-based configuration is being phased out in favor of CiliumLoadBalancerIPPool CRD.

### Step 2: Create L2 Announcement Policy

This policy defines **which nodes** announce IPs on **which interfaces**.

Create `l2-announcement-policy.yaml`:

```yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumL2AnnouncementPolicy
metadata:
  name: default-l2-policy
spec:
  serviceSelector:
    matchLabels: {} # (1)!
  nodeSelector:
    matchExpressions:
      - key: node-role.kubernetes.io/control-plane
        operator: DoesNotExist # (2)!
  interfaces:
    - ^enp0s.* # (3)!
    - ^eth0$
    - ^ens18$
  externalIPs: true
  loadBalancerIPs: true
```

1. Matches all services (no label filtering)
2. Only worker nodes announce (exclude control plane)
3. Regex patterns for common Talos interface names

Apply:

```bash
kubectl apply -f l2-announcement-policy.yaml
```

### Step 3: Verify Policy Creation

```bash
kubectl get ciliuml2announcementpolicy
```

Expected output:

```
NAME                 AGE
default-l2-policy    10s
```

Check details:

```bash
kubectl describe ciliuml2announcementpolicy default-l2-policy
```

---

## Configuring Network Interface Selection

### Find Your Node's Network Interface

On Talos, list network interfaces:

```bash
talosctl get links -n <node-ip>
```

Example output:

```
NAME     TYPE     ENABLED
enp0s1   ether    true
lo       loopback true
cilium_host ether true
cilium_net ether  true
```

Or from within a pod:

```bash
kubectl run net-debug --rm -it --image=nicolaka/netshoot -- ip link show
```

### Common Interface Patterns

| Environment | Interface Name     | Regex Pattern   |
| ----------- | ------------------ | --------------- |
| VirtualBox  | `enp0s3`, `enp0s8` | `^enp0s.*`      |
| VMware      | `ens192`, `ens224` | `^ens.*`        |
| Proxmox     | `ens18`, `ens19`   | `^ens1[89]$`    |
| Cloud VM    | `eth0`, `eth1`     | `^eth[01]$`     |
| Bare Metal  | `eno1`, `enp1s0`   | Device-specific |

### Update L2 Policy with Correct Interface

Edit your policy:

```bash
kubectl edit ciliuml2announcementpolicy default-l2-policy
```

Update the `interfaces` section:

```yaml
spec:
  interfaces:
    - ^enp0s1$ # Exact match for VirtualBox
```

!!! tip "Testing Multiple Patterns"
Use multiple patterns to cover different node types:

    ```yaml
    interfaces:
      - ^enp0s.*   # VirtualBox VMs
      - ^ens18$    # Proxmox VMs
      - ^eth0$     # Cloud instances
    ```

---

## Configuring Traffic Policy

The `externalTrafficPolicy` setting affects how traffic reaches your pods.

### Cluster vs Local Traffic Policy

Create a test service to compare:

=== "externalTrafficPolicy: Cluster"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-cluster-policy
    spec:
      type: LoadBalancer
      externalTrafficPolicy: Cluster  # (1)!
      selector:
        app: nginx
      ports:
        - port: 80
          targetPort: 80
    ```

    1. **Default behavior**
        - ✅ Load balances across all pods
        - ✅ Works even if node announcing IP has no local pods
        - ❌ Source IP is SNAT'd (client IP lost)
        - ❌ Extra network hop possible

=== "externalTrafficPolicy: Local"

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-local-policy
    spec:
      type: LoadBalancer
      externalTrafficPolicy: Local  # (1)!
      selector:
        app: nginx
      ports:
        - port: 80
          targetPort: 80
    ```

    1. **Preserve source IP**
        - ✅ Preserves client source IP
        - ✅ No extra hops (direct to local pod)
        - ❌ Only works if announcing node has local pod
        - ❌ Uneven load distribution possible

### When to Use Each Policy

| Scenario                             | Recommended Policy | Reason                           |
| ------------------------------------ | ------------------ | -------------------------------- |
| Web applications needing client IP   | `Local`            | Access logs show real client IPs |
| Multi-replica high-availability apps | `Cluster`          | Better load distribution         |
| Security policies based on source IP | `Local`            | Network policies see real IPs    |
| Single-replica applications          | Either             | No difference                    |
| Ingress controllers (Traefik, nginx) | `Local`            | Pass client IP to backend apps   |

### Verify Traffic Policy Behavior

Deploy test workload:

```bash
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --type=LoadBalancer --port=80 --external-traffic-policy=Local
```

Check pod distribution:

```bash
kubectl get pods -o wide -l app=nginx
```

Get LoadBalancer IP:

```bash
kubectl get svc nginx
```

Test from external client:

```bash
curl -v http://<LOADBALANCER_IP>
```

Check nginx logs for source IP:

```bash
kubectl logs -l app=nginx | grep "GET /"
```

With `Local` policy, you should see your real client IP. With `Cluster`, you'll see a cluster-internal IP.

---

## Advanced Configuration Options

### 1. Multiple IP Pools with Service Selectors

Create separate pools for different environments:

```yaml
---
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  name: production-pool
spec:
  blocks:
    - cidr: "192.168.10.64/28"
  serviceSelector:
    matchLabels:
      environment: production
---
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  name: development-pool
spec:
  blocks:
    - cidr: "192.168.20.64/28"
  serviceSelector:
    matchLabels:
      environment: development
```

Label your service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: prod-app
  labels:
    environment: production
spec:
  type: LoadBalancer
  # ...
```

### 2. Node-Specific Announcement Policies

Announce only from specific nodes:

```yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumL2AnnouncementPolicy
metadata:
  name: edge-nodes-only
spec:
  nodeSelector:
    matchLabels:
      node-role: edge # (1)!
  interfaces:
    - ^enp0s1$
  loadBalancerIPs: true
```

1. Label your edge nodes: `kubectl label node worker-01 node-role=edge`

### 3. Lease Configuration Tuning

Adjust leader election behavior in Helm values:

```yaml
l2announcements:
  enabled: true
  leaseDuration: 180s # (1)!
  leaseRenewDeadline: 90s # (2)!
  leaseRetryPeriod: 2s # (3)!
```

1. How long a leader holds the lease (default: 120s)
2. How long to retry renewal before giving up (default: 60s)
3. How often to retry lease operations (default: 1s)

!!! info "Lease Tuning Guidelines" - **Stable networks**: Increase `leaseDuration` (e.g., 300s) to reduce churn - **Unstable networks**: Decrease `leaseDuration` (e.g., 60s) for faster failover - **High-latency networks**: Increase `leaseRetryPeriod` (e.g., 5s)

### 4. Service-Specific IP Assignment

Request specific IP from pool:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: critical-app
  annotations:
    io.cilium/lb-ipam-ips: "192.168.10.75" # (1)!
spec:
  type: LoadBalancer
  loadBalancerClass: io.cilium/l2-announcer # (2)!
  selector:
    app: critical-app
  ports:
    - port: 443
```

1. Request specific IP (must be in configured pool)
2. Explicitly use Cilium L2 announcer

---

## Verification and Testing

### Check IP Pool Status

```bash
kubectl get ciliumloadbalancerippool
```

Example output:

```
NAME          DISABLED   CONFLICTING   IPS AVAILABLE   AGE
prod-pool     false      false         14              5m
```

Detailed view:

```bash
kubectl describe ciliumloadbalancerippool prod-pool
```

### Check L2 Announcement Policy Status

```bash
kubectl get ciliuml2announcementpolicy -o yaml
```

Look for any status conditions or errors.

### Verify Service Gets IP

Create test service:

```bash
kubectl create deployment test-nginx --image=nginx
kubectl expose deployment test-nginx --type=LoadBalancer --port=80
```

Wait for EXTERNAL-IP:

```bash
kubectl get svc test-nginx -w
```

Should transition from `<pending>` to actual IP address within seconds.

### Test ARP Resolution

From a machine on the same LAN:

```bash
ping -c 3 <LOADBALANCER_IP>
```

Check ARP table:

```bash
arp -a | grep <LOADBALANCER_IP>
```

Expected output:

```
? (192.168.10.75) at aa:bb:cc:dd:ee:ff [ether] on enp0s1
```

Should show MAC address of the Kubernetes node announcing the IP.

### Test HTTP Connectivity

```bash
curl -v http://<LOADBALANCER_IP>
```

Should receive response from nginx.

### Check Cilium Logs

View L2 announcement activity:

```bash
kubectl logs -n kube-system -l k8s-app=cilium --tail=50 | grep -i "l2\|announce\|lease"
```

Look for:

```
level=info msg="Announcing LoadBalancer IP" ip=192.168.10.75 service=default/test-nginx
level=info msg="Acquired lease for L2 announcement" service=default/test-nginx
```

---

## Configuration Comparison Table

| Configuration Method           | Use Case                 | Pros                             | Cons                          |
| ------------------------------ | ------------------------ | -------------------------------- | ----------------------------- |
| **Helm values**                | Production deployments   | Version controlled, reproducible | Requires cluster upgrade      |
| **CiliumLoadBalancerIPPool**   | Dynamic IP management    | Easy updates, namespace-aware    | Requires L2 policy separately |
| **CiliumL2AnnouncementPolicy** | Interface/node selection | Flexible targeting               | Must match IP pool config     |
| **ConfigMap (legacy)**         | Migration from MetalLB   | Familiar syntax                  | Deprecated, limited features  |
| **Service annotations**        | Specific IP requests     | Fine-grained control             | Manual management per service |

---

## Migrating from Manual Installation

If Cilium was installed manually (not via Helm), migrate to Helm management:

### Step 1: Backup Current Configuration

```bash
kubectl get daemonset cilium -n kube-system -o yaml > cilium-daemonset-backup.yaml
kubectl get configmap cilium-config -n kube-system -o yaml > cilium-config-backup.yaml
```

### Step 2: Generate Equivalent Helm Values

```bash
cilium install --dry-run-helm-values > cilium-equivalent-values.yaml
```

### Step 3: Uninstall Manual Installation

```bash
cilium uninstall
```

!!! danger "Service Disruption"
This will briefly interrupt networking. Plan for maintenance window.

### Step 4: Install via Helm

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium \
  --namespace kube-system \
  --values cilium-equivalent-values.yaml
```

### Step 5: Re-apply L2 Configuration

```bash
kubectl apply -f cilium-l2-rbac.yaml
kubectl apply -f lb-ip-pool.yaml
kubectl apply -f l2-announcement-policy.yaml
```

---

## Troubleshooting Common Issues

### Issue: Helm Upgrade Fails

**Error**: `Error: UPGRADE FAILED: cannot patch "cilium" with kind DaemonSet`

**Solution**: Use `--force` flag:

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values --values cilium-values.yaml --force
```

### Issue: L2 Feature Not Enabled After Upgrade

**Check operator logs**:

```bash
kubectl logs -n kube-system deployment/cilium-operator
```

If you see `L2 announcements: Disabled`, verify Helm values:

```bash
helm get values cilium -n kube-system | grep -A5 l2announcements
```

### Issue: RBAC Errors in Logs

**Error**: `cannot create resource "leases" in API group "coordination.k8s.io"`

**Solution**: Ensure RBAC was applied:

```bash
kubectl get role cilium-l2-announcement -n kube-system
kubectl get rolebinding cilium-l2-announcement -n kube-system
```

Re-apply if missing:

```bash
kubectl apply -f cilium-l2-rbac.yaml
```

### Issue: Wrong Interface Selected

**Symptom**: IP assigned but not accessible via ARP.

**Check interface regex**:

```bash
kubectl get ciliuml2announcementpolicy default-l2-policy -o jsonpath='{.spec.interfaces}'
```

Compare with node interfaces:

```bash
talosctl get links -n <node-ip>
```

Update policy with correct interface pattern.

---

## Next Steps

After configuring L2 announcements:

1. **Deploy real workloads** with LoadBalancer services
2. **Configure DNS** to point to LoadBalancer IPs
3. **Set up monitoring** for L2 announcement metrics
4. **Test failover** by cordoning nodes and watching lease migration
5. **Review troubleshooting guide** for operational issues

---

## Related Documentation

- [Tutorial: Deploy Cilium with L2 LoadBalancer on Talos](../../../../../tutorials/containers/kubernetes/networking/cilium/cilium-l2-loadbalancer-talos.md)
- [How to: Troubleshoot Cilium LoadBalancer Issues](cilium-troubleshoot-loadbalancer.md)
- [Explanation: Cilium L2 Networking Architecture](../../../../../explanation/containers/kubernetes/networking/cilium/cilium-l2-networking-talos.md)

---

## References

- [Cilium LB-IPAM Documentation](https://docs.cilium.io/en/stable/network/lb-ipam/)
- [Cilium L2 Announcements Documentation](https://docs.cilium.io/en/stable/network/l2-announcements/)
- [Talos Cilium Deployment Guide](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium/)
- [Kubernetes Service External Traffic Policy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip)
