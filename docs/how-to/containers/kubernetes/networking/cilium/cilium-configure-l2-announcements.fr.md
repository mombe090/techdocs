# Comment configurer les annonces L2 de Cilium sur Talos Linux

**Objectif** : Configurer Cilium pour annoncer les IP LoadBalancer sur les réseaux de couche 2 pour l'accessibilité externe.

**Scénario** : Vous avez un cluster Talos Linux avec Cilium CNI et vous avez besoin que les services LoadBalancer soient accessibles depuis l'extérieur du cluster sans MetalLB ou intégration de fournisseur cloud.

**Durée** : 20-30 minutes

**Prérequis** :

- Cluster Talos Linux (v1.x)
- Cilium installé comme CNI (v1.16.0+)
- Accès `kubectl` au cluster
- Helm 3 installé (recommandé pour les mises à jour)
- Pool d'adresses IP disponible sur votre LAN

---

## Comprendre l'approche de configuration

Les annonces L2 de Cilium nécessitent trois composants principaux :

1. **Configuration LB-IPAM** - Gestion du pool d'IP
2. **Annonces L2 activées** - Activation de la fonctionnalité
3. **Politique d'annonce L2** - Interface réseau et sélection des nœuds

Vous pouvez les configurer en utilisant :

=== "Valeurs Helm (Recommandé)"

    **Avantages** :

    - Versionné
    - Plus facile à maintenir
    - Déploiements reproductibles
    - Piste d'audit claire

    **Inconvénients** :

    - Nécessite des connaissances Helm
    - Mise à jour complète du cluster nécessaire

=== "kubectl Apply (Alternative)"

    **Avantages** :

    - Changements rapides
    - Pas de mise à jour à l'échelle du cluster
    - Bon pour les tests

    **Inconvénients** :

    - Risque de dérive de configuration
    - Plus difficile de suivre les changements
    - Doit gérer RBAC séparément

!!! tip "Bonne pratique"
Utilisez les valeurs Helm pour les environnements de production. Utilisez `kubectl apply` uniquement pour les tests ou les correctifs temporaires.

---

## Méthode 1 : Configurer avec les valeurs Helm

### Étape 1 : Vérifier l'installation actuelle de Cilium

D'abord, vérifiez que Cilium est installé via Helm :

```bash
helm list -n kube-system
```

Sortie attendue :

```
NAME    NAMESPACE       REVISION        UPDATED         STATUS          CHART
cilium  kube-system     1               2024-12-05      deployed        cilium-1.16.5
```

Si Cilium n'a pas été installé via Helm, voir le [Guide de migration](#migrer-depuis-une-installation-manuelle).

### Étape 2 : Exporter les valeurs actuelles

```bash
helm get values cilium -n kube-system > cilium-current-values.yaml
```

!!! warning "Paramètres spécifiques à Talos"
Ne modifiez pas ces paramètres requis par Talos :

    - `k8sServiceHost: localhost`
    - `k8sServicePort: "7445"` (KubePrism)
    - `cgroup.autoMount.enabled: false`
    - `cgroup.hostRoot: /sys/fs/cgroup`

### Étape 3 : Créer les valeurs Helm complètes

Créez `cilium-values.yaml` avec le support L2 activé :

```yaml
# Configuration API Kubernetes spécifique à Talos
k8sServiceHost: localhost
k8sServicePort: "7445"

# Configuration cgroup v2 de Talos
cgroup:
  autoMount:
    enabled: false
  hostRoot: /sys/fs/cgroup

# Gestion des adresses IP (IPAM)
ipam:
  mode: kubernetes
  operator:
    clusterPoolIPv4PodCIDRList: ["10.244.0.0/16"] # (1)!

# Gestion des adresses IP LoadBalancer
l2announcements:
  enabled: true # (2)!
  leaseDuration: 120s
  leaseRenewDeadline: 60s
  leaseRetryPeriod: 1s

externalIPs:
  enabled: true

# Activer les fonctionnalités nécessaires
ingressController:
  enabled: false
  loadbalancerMode: dedicated

# Support Gateway API (optionnel)
gatewayAPI:
  enabled: false

# Plan de contrôle BGP (si utilisation de BGP avec L2)
bgpControlPlane:
  enabled: false

# Sécurité et surveillance
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

# Remplacement de kubeproxy
kubeProxyReplacement: true
```

1. Correspond au CIDR des pods de votre cluster
2. Ceci active la fonctionnalité d'annonces L2

### Étape 4 : Créer les permissions RBAC

Cilium a besoin de permissions RBAC pour l'élection de leader utilisant les leases.

Créez `cilium-l2-rbac.yaml` :

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

Appliquez RBAC :

```bash
kubectl apply -f cilium-l2-rbac.yaml
```

### Étape 5 : Mettre à jour Cilium avec les nouvelles valeurs

```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --values cilium-values.yaml \
  --version 1.16.5
```

!!! tip "Sélection de version"
Vérifiez les versions disponibles : `helm search repo cilium/cilium --versions`

Attendez le déploiement :

```bash
kubectl rollout status daemonset/cilium -n kube-system
kubectl rollout status deployment/cilium-operator -n kube-system
```

### Étape 6 : Vérifier la fonctionnalité d'annonces L2

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg status | grep -i l2
```

Sortie attendue :

```
L2 Announcements:     Enabled
```

Vérifiez également les logs de l'opérateur :

```bash
kubectl logs -n kube-system deployment/cilium-operator | grep -i l2
```

Devrait afficher :

```
level=info msg="L2 announcements enabled"
```

---

## Méthode 2 : Configurer avec des pools IP et des politiques

### Étape 1 : Créer un pool d'adresses IP

Choisissez entre **CiliumLoadBalancerIPPool** (plus récent, recommandé) ou **ConfigMap** (legacy).

=== "CiliumLoadBalancerIPPool (Recommandé)"

    Créez `lb-ip-pool.yaml` :

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

    1. Fournit les IP : 192.168.10.64 - 192.168.10.79 (16 adresses, ~14 utilisables)

    Appliquez :

    ```bash
    kubectl apply -f lb-ip-pool.yaml
    ```

=== "ConfigMap (Legacy)"

    Créez `lb-ip-pool-configmap.yaml` :

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

    Appliquez :

    ```bash
    kubectl apply -f lb-ip-pool-configmap.yaml
    ```

    !!! warning "Approche obsolète"
        La configuration basée sur ConfigMap est en cours de suppression progressive au profit de la CRD CiliumLoadBalancerIPPool.

### Étape 2 : Créer une politique d'annonce L2

Cette politique définit **quels nœuds** annoncent les IP sur **quelles interfaces**.

Créez `l2-announcement-policy.yaml` :

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

1. Correspond à tous les services (pas de filtrage par label)
2. Seuls les nœuds workers annoncent (exclut le control plane)
3. Motifs regex pour les noms d'interface Talos courants

Appliquez :

```bash
kubectl apply -f l2-announcement-policy.yaml
```

### Étape 3 : Vérifier la création de la politique

```bash
kubectl get ciliuml2announcementpolicy
```

Sortie attendue :

```
NAME                 AGE
default-l2-policy    10s
```

Vérifiez les détails :

```bash
kubectl describe ciliuml2announcementpolicy default-l2-policy
```

---

## Configuration de la sélection d'interface réseau

### Trouver l'interface réseau de votre nœud

Sur Talos, listez les interfaces réseau :

```bash
talosctl get links -n <node-ip>
```

Exemple de sortie :

```
NAME     TYPE     ENABLED
enp0s1   ether    true
lo       loopback true
cilium_host ether true
cilium_net ether  true
```

Ou depuis un pod :

```bash
kubectl run net-debug --rm -it --image=nicolaka/netshoot -- ip link show
```

### Motifs d'interface courants

| Environnement | Nom d'interface    | Motif Regex                |
| ------------- | ------------------ | -------------------------- |
| VirtualBox    | `enp0s3`, `enp0s8` | `^enp0s.*`                 |
| VMware        | `ens192`, `ens224` | `^ens.*`                   |
| Proxmox       | `ens18`, `ens19`   | `^ens1[89]$`               |
| VM Cloud      | `eth0`, `eth1`     | `^eth[01]$`                |
| Bare Metal    | `eno1`, `enp1s0`   | Spécifique au périphérique |

### Mettre à jour la politique L2 avec l'interface correcte

Éditez votre politique :

```bash
kubectl edit ciliuml2announcementpolicy default-l2-policy
```

Mettez à jour la section `interfaces` :

```yaml
spec:
  interfaces:
    - ^enp0s1$ # Correspondance exacte pour VirtualBox
```

!!! tip "Tester plusieurs motifs"
Utilisez plusieurs motifs pour couvrir différents types de nœuds :

    ```yaml
    interfaces:
      - ^enp0s.*   # VMs VirtualBox
      - ^ens18$    # VMs Proxmox
      - ^eth0$     # Instances cloud
    ```

---

## Configuration de la politique de trafic

Le paramètre `externalTrafficPolicy` affecte comment le trafic atteint vos pods.

### Politique de trafic Cluster vs Local

Créez un service de test pour comparer :

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

    1. **Comportement par défaut**
       - ✅ Répartit la charge sur tous les pods
       - ✅ Fonctionne même si le nœud annonçant l'IP n'a pas de pods locaux
       - ❌ L'IP source est SNAT (perte de l'IP client)
       - ❌ Saut réseau supplémentaire possible

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

    1. **Préserve l'IP source**
       - ✅ Préserve l'IP source du client
       - ✅ Pas de sauts supplémentaires (direct vers le pod local)
       - ❌ Fonctionne uniquement si le nœud annonçant a un pod local
       - ❌ Distribution de charge inégale possible

### Quand utiliser chaque politique

| Scénario                                        | Politique recommandée | Raison                                               |
| ----------------------------------------------- | --------------------- | ---------------------------------------------------- |
| Applications web nécessitant l'IP client        | `Local`               | Les logs d'accès affichent les vraies IP des clients |
| Applications haute disponibilité multi-réplicas | `Cluster`             | Meilleure distribution de charge                     |
| Politiques de sécurité basées sur l'IP source   | `Local`               | Les politiques réseau voient les vraies IP           |
| Applications à réplica unique                   | L'un ou l'autre       | Pas de différence                                    |
| Contrôleurs Ingress (Traefik, nginx)            | `Local`               | Transmet l'IP client aux applications backend        |

### Vérifier le comportement de la politique de trafic

Déployez une charge de travail de test :

```bash
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --type=LoadBalancer --port=80 --external-traffic-policy=Local
```

Vérifiez la distribution des pods :

```bash
kubectl get pods -o wide -l app=nginx
```

Obtenez l'IP LoadBalancer :

```bash
kubectl get svc nginx
```

Testez depuis un client externe :

```bash
curl -v http://<LOADBALANCER_IP>
```

Vérifiez les logs nginx pour l'IP source :

```bash
kubectl logs -l app=nginx | grep "GET /"
```

Avec la politique `Local`, vous devriez voir votre vraie IP client. Avec `Cluster`, vous verrez une IP interne du cluster.

---

## Options de configuration avancées

### 1. Pools IP multiples avec sélecteurs de service

Créez des pools séparés pour différents environnements :

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

Étiquetez votre service :

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

### 2. Politiques d'annonce spécifiques aux nœuds

Annoncez uniquement depuis des nœuds spécifiques :

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

1. Étiquetez vos nœuds edge : `kubectl label node worker-01 node-role=edge`

### 3. Ajustement de la configuration des leases

Ajustez le comportement de l'élection de leader dans les valeurs Helm :

```yaml
l2announcements:
  enabled: true
  leaseDuration: 180s # (1)!
  leaseRenewDeadline: 90s # (2)!
  leaseRetryPeriod: 2s # (3)!
```

1. Combien de temps un leader détient le lease (défaut : 120s)
2. Combien de temps pour réessayer le renouvellement avant d'abandonner (défaut : 60s)
3. À quelle fréquence réessayer les opérations de lease (défaut : 1s)

!!! info "Directives d'ajustement des leases" - **Réseaux stables** : Augmentez `leaseDuration` (ex. 300s) pour réduire le churn - **Réseaux instables** : Diminuez `leaseDuration` (ex. 60s) pour un basculement plus rapide - **Réseaux à haute latence** : Augmentez `leaseRetryPeriod` (ex. 5s)

### 4. Attribution d'IP spécifique au service

Demandez une IP spécifique du pool :

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

1. Demande une IP spécifique (doit être dans le pool configuré)
2. Utilise explicitement l'annonceur L2 de Cilium

---

## Vérification et tests

### Vérifier le statut du pool IP

```bash
kubectl get ciliumloadbalancerippool
```

Exemple de sortie :

```
NAME          DISABLED   CONFLICTING   IPS AVAILABLE   AGE
prod-pool     false      false         14              5m
```

Vue détaillée :

```bash
kubectl describe ciliumloadbalancerippool prod-pool
```

### Vérifier le statut de la politique d'annonce L2

```bash
kubectl get ciliuml2announcementpolicy -o yaml
```

Recherchez toutes conditions de statut ou erreurs.

### Vérifier que le service obtient une IP

Créez un service de test :

```bash
kubectl create deployment test-nginx --image=nginx
kubectl expose deployment test-nginx --type=LoadBalancer --port=80
```

Attendez l'EXTERNAL-IP :

```bash
kubectl get svc test-nginx -w
```

Devrait passer de `<pending>` à une adresse IP réelle en quelques secondes.

### Tester la résolution ARP

Depuis une machine sur le même LAN :

```bash
ping -c 3 <LOADBALANCER_IP>
```

Vérifiez la table ARP :

```bash
arp -a | grep <LOADBALANCER_IP>
```

Sortie attendue :

```
? (192.168.10.75) at aa:bb:cc:dd:ee:ff [ether] on enp0s1
```

Devrait afficher l'adresse MAC du nœud Kubernetes annonçant l'IP.

### Tester la connectivité HTTP

```bash
curl -v http://<LOADBALANCER_IP>
```

Devrait recevoir une réponse de nginx.

### Vérifier les logs de Cilium

Voir l'activité d'annonce L2 :

```bash
kubectl logs -n kube-system -l k8s-app=cilium --tail=50 | grep -i "l2\|announce\|lease"
```

Recherchez :

```
level=info msg="Announcing LoadBalancer IP" ip=192.168.10.75 service=default/test-nginx
level=info msg="Acquired lease for L2 announcement" service=default/test-nginx
```

---

## Tableau de comparaison des configurations

| Méthode de configuration       | Cas d'usage                | Avantages                                     | Inconvénients                            |
| ------------------------------ | -------------------------- | --------------------------------------------- | ---------------------------------------- |
| **Valeurs Helm**               | Déploiements de production | Versionné, reproductible                      | Nécessite une mise à jour du cluster     |
| **CiliumLoadBalancerIPPool**   | Gestion dynamique des IP   | Mises à jour faciles, sensible aux namespaces | Nécessite une politique L2 séparée       |
| **CiliumL2AnnouncementPolicy** | Sélection interface/nœud   | Ciblage flexible                              | Doit correspondre à la config du pool IP |
| **ConfigMap (legacy)**         | Migration depuis MetalLB   | Syntaxe familière                             | Obsolète, fonctionnalités limitées       |
| **Annotations de service**     | Demandes d'IP spécifiques  | Contrôle fin                                  | Gestion manuelle par service             |

---

## Migration depuis une installation manuelle

Si Cilium a été installé manuellement (pas via Helm), migrez vers la gestion Helm :

### Étape 1 : Sauvegarder la configuration actuelle

```bash
kubectl get daemonset cilium -n kube-system -o yaml > cilium-daemonset-backup.yaml
kubectl get configmap cilium-config -n kube-system -o yaml > cilium-config-backup.yaml
```

### Étape 2 : Générer les valeurs Helm équivalentes

```bash
cilium install --dry-run-helm-values > cilium-equivalent-values.yaml
```

### Étape 3 : Désinstaller l'installation manuelle

```bash
cilium uninstall
```

!!! danger "Interruption de service"
Cela interrompra brièvement le réseau. Planifiez une fenêtre de maintenance.

### Étape 4 : Installer via Helm

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium \
  --namespace kube-system \
  --values cilium-equivalent-values.yaml
```

### Étape 5 : Réappliquer la configuration L2

```bash
kubectl apply -f cilium-l2-rbac.yaml
kubectl apply -f lb-ip-pool.yaml
kubectl apply -f l2-announcement-policy.yaml
```

---

## Résolution des problèmes courants

### Problème : Échec de la mise à jour Helm

**Erreur** : `Error: UPGRADE FAILED: cannot patch "cilium" with kind DaemonSet`

**Solution** : Utilisez le flag `--force` :

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values --values cilium-values.yaml --force
```

### Problème : Fonctionnalité L2 non activée après la mise à jour

**Vérifiez les logs de l'opérateur** :

```bash
kubectl logs -n kube-system deployment/cilium-operator
```

Si vous voyez `L2 announcements: Disabled`, vérifiez les valeurs Helm :

```bash
helm get values cilium -n kube-system | grep -A5 l2announcements
```

### Problème : Erreurs RBAC dans les logs

**Erreur** : `cannot create resource "leases" in API group "coordination.k8s.io"`

**Solution** : Assurez-vous que RBAC a été appliqué :

```bash
kubectl get role cilium-l2-announcement -n kube-system
kubectl get rolebinding cilium-l2-announcement -n kube-system
```

Réappliquez si manquant :

```bash
kubectl apply -f cilium-l2-rbac.yaml
```

### Problème : Mauvaise interface sélectionnée

**Symptôme** : IP attribuée mais non accessible via ARP.

**Vérifiez le regex de l'interface** :

```bash
kubectl get ciliuml2announcementpolicy default-l2-policy -o jsonpath='{.spec.interfaces}'
```

Comparez avec les interfaces du nœud :

```bash
talosctl get links -n <node-ip>
```

Mettez à jour la politique avec le bon motif d'interface.

---

## Prochaines étapes

Après avoir configuré les annonces L2 :

1. **Déployez des charges de travail réelles** avec des services LoadBalancer
2. **Configurez le DNS** pour pointer vers les IP LoadBalancer
3. **Configurez la surveillance** des métriques d'annonce L2
4. **Testez le basculement** en cordonnant les nœuds et en observant la migration des leases
5. **Consultez le guide de dépannage** pour les problèmes opérationnels

---

## Documentation connexe

- [Tutoriel : Déployer Cilium avec LoadBalancer L2 sur Talos](../../../../../tutorials/containers/kubernetes/networking/cilium/cilium-l2-loadbalancer-talos.fr.md)
- [Comment : Résoudre les problèmes de LoadBalancer Cilium](cilium-troubleshoot-loadbalancer.md)
- [Explication : Architecture réseau L2 de Cilium](../../../../../explanation/containers/kubernetes/networking/cilium/cilium-l2-networking-talos.fr.md)

---

## Références

- [Documentation Cilium LB-IPAM](https://docs.cilium.io/en/stable/network/lb-ipam/)
- [Documentation des annonces L2 de Cilium](https://docs.cilium.io/en/stable/network/l2-announcements/)
- [Guide de déploiement Cilium sur Talos](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium/)
- [Politique de trafic externe des services Kubernetes](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip)
