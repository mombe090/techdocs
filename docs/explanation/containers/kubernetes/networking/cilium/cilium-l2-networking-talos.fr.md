# Architecture réseau L2 de Cilium sur Talos Linux

!!! warning "Travaux en cours"

    Ce document d'explication est actuellement en cours de développement. Revenez bientôt pour une plongée approfondie complète dans les concepts et l'architecture du réseau L2 de Cilium.

## Contenu prévu

Cette page fournira une explication complète de :

### Principes fondamentaux du réseau de couche 2

- **Couche 2 du modèle OSI** - Concepts de la couche liaison de données
- **ARP (Address Resolution Protocol)** - Comment fonctionne la découverte d'adresses MAC
- **Domaines de diffusion** - Limites du réseau L2
- **Tables d'adresses MAC** - Apprentissage et transfert des commutateurs

### Architecture Cilium LB-IPAM {#cilium-vs-metallb}

- **Pourquoi Cilium LB-IPAM ?** - Comparaison avec MetalLB
  - Approche intégrée vs autonome
  - Avantages d'eBPF par rapport aux implémentations traditionnelles
  - Caractéristiques d'efficacité des ressources et de performance
  - Comparaison de la complexité opérationnelle
- **Composants LB-IPAM** - Gestion des pools d'IP, logique d'allocation
- **Intégration avec CNI** - Comment Cilium gère à la fois le réseau des pods et les IP LoadBalancer

### Mécanisme d'annonce L2

- **Élection du leader** - Comment Cilium sélectionne le nœud qui annonce une IP
  - Coordination basée sur les baux Kubernetes
  - Basculement et haute disponibilité
  - Scénarios de réélection du leader
- **Répondeur ARP** - Comment le nœud leader répond aux requêtes ARP
- **ARP gratuit** - Annonce de la propriété IP sur le réseau
- **Sélection d'interface** - Pourquoi la configuration de l'interface est importante

### Traitement des paquets eBPF

- **Programmes eBPF** - Comment Cilium traite les paquets dans le noyau
- **XDP (eXpress Data Path)** - Traitement rapide des paquets
- **Suivi des connexions** - Maintien de l'état pour les connexions LoadBalancer
- **NAT et SNAT** - Comportement de traduction d'adresse source

### Politiques de trafic {#traffic-policies}

- **Politique Cluster** - Équilibrage de charge sur tous les nœuds
  - Diagrammes de flux de paquets
  - Implications SNAT
  - Caractéristiques de performance
- **Politique Local** - Routage direct vers les pods locaux
  - Préservation de l'IP source
  - Comportement des contrôles de santé
  - Déséquilibres de trafic potentiels

### Considérations spécifiques à Talos

- **Intégration KubePrism** - Pourquoi l'accès au serveur API est important
- **Exigences CGroup v2** - Fonctionnalités du noyau Linux moderne
- **Contextes de sécurité** - Restrictions de capacités sur Talos
- **Nommage des interfaces** - Identification des périphériques réseau

## Documentation connexe

- [Tutoriel : Déployer Cilium avec LoadBalancer L2 sur Talos](../../../../../tutorials/containers/kubernetes/networking/cilium/cilium-l2-loadbalancer-talos.fr.md) - Guide de configuration étape par étape
- [Comment : Configurer les annonces L2](../../../../../how-to/containers/kubernetes/networking/cilium/cilium-configure-l2-announcements.fr.md) - Modèles de configuration
- [Comment : Dépanner le LoadBalancer](../../../../../how-to/containers/kubernetes/networking/cilium/cilium-troubleshoot-loadbalancer.md) - Diagnostic des problèmes

## Références

- [Documentation Cilium - LB-IPAM](https://docs.cilium.io/en/stable/network/lb-ipam/)
- [Documentation Cilium - Annonces L2](https://docs.cilium.io/en/stable/network/l2-announcements/)
- [Documentation eBPF](https://ebpf.io/what-is-ebpf/)
- [Documentation Talos Linux](https://docs.siderolabs.com/)

---

**État :** 🚧 En construction  
**Achèvement estimé :** À déterminer

Pour une aide immédiate, consultez les guides tutoriel et pratiques liés ci-dessus.
