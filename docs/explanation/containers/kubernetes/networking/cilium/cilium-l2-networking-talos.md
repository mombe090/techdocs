# Cilium L2 Networking Architecture on Talos Linux

!!! warning "Work in Progress"

    This explanation document is currently under development. Check back soon for a comprehensive deep dive into Cilium L2 networking concepts and architecture.

## Planned Content

This page will provide a comprehensive explanation of:

### Layer 2 Networking Fundamentals

- **OSI Model Layer 2** - Data Link Layer concepts
- **ARP (Address Resolution Protocol)** - How MAC address discovery works
- **Broadcast domains** - L2 network boundaries
- **MAC address tables** - Switch learning and forwarding

### Cilium LB-IPAM Architecture {#cilium-vs-metallb}

- **Why Cilium LB-IPAM?** - Comparison with MetalLB
  - Integrated vs standalone approach
  - eBPF advantages over traditional implementations
  - Resource efficiency and performance characteristics
  - Operational complexity comparison
- **LB-IPAM components** - IP pool management, allocation logic
- **Integration with CNI** - How Cilium manages both pod networking and LoadBalancer IPs

### L2 Announcement Mechanism

- **Leader election** - How Cilium selects which node announces an IP
  - Kubernetes lease-based coordination
  - Failover and high availability
  - Leader re-election scenarios
- **ARP responder** - How the leader node responds to ARP requests
- **Gratuitous ARP** - Announcing IP ownership on the network
- **Interface selection** - Why interface configuration matters

### eBPF Packet Processing

- **eBPF programs** - How Cilium processes packets in-kernel
- **XDP (eXpress Data Path)** - Fast packet processing
- **Connection tracking** - Maintaining state for LoadBalancer connections
- **NAT and SNAT** - Source address translation behavior

### Traffic Policies {#traffic-policies}

- **Cluster policy** - Load balancing across all nodes
  - Packet flow diagrams
  - SNAT implications
  - Performance characteristics
- **Local policy** - Direct routing to local pods
  - Source IP preservation
  - Health check behavior
  - Potential traffic imbalances

### Talos-Specific Considerations

- **KubePrism integration** - Why API server access matters
- **CGroup v2 requirements** - Modern Linux kernel features
- **Security contexts** - Capability restrictions on Talos
- **Interface naming** - Network device identification

## Related Documentation

- [Tutorial: Deploy Cilium with L2 LoadBalancer on Talos](../../../../../tutorials/containers/kubernetes/networking/cilium/cilium-l2-loadbalancer-talos.md) - Step-by-step setup guide
- [How-to: Configure L2 Announcements](../../../../../how-to/containers/kubernetes/networking/cilium/cilium-configure-l2-announcements.md) - Configuration patterns
- [How-to: Troubleshoot LoadBalancer](../../../../../how-to/containers/kubernetes/networking/cilium/cilium-troubleshoot-loadbalancer.md) - Problem diagnosis

## References

- [Cilium Documentation - LB-IPAM](https://docs.cilium.io/en/stable/network/lb-ipam/)
- [Cilium Documentation - L2 Announcements](https://docs.cilium.io/en/stable/network/l2-announcements/)
- [eBPF Documentation](https://ebpf.io/what-is-ebpf/)
- [Talos Linux Documentation](https://docs.siderolabs.com/)

---

**Status:** 🚧 Under Construction  
**Estimated Completion:** TBD

For immediate help, refer to the tutorial and how-to guides linked above.
