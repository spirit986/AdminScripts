## `kubectl`
...

---
## `helm`
[Using Helm Basics](https://helm.sh/docs/intro/using_helm/)

### List
List everything installed with helm on the current cluster
```bash
$ helm list --all-namespaces

NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
cert-manager            cert-manager    1               2023-06-16 23:54:26.4188824 +0200 CEST  deployed        cert-manager-v1.12.0            v1.12.0
ingress-nginx           ingress-nginx   1               2023-06-16 23:56:29.0936339 +0200 CEST  deployed        ingress-nginx-4.6.1             1.7.1
kube-prometheus-stack   monitoring      2               2023-06-17 00:45:01.7381121 +0200 CEST  deployed        kube-prometheus-stack-46.8.0    v0.65.2
longhorn                longhorn-system 1               2023-06-17 10:19:09.5922474 +0200 CEST  deployed        longhorn-1.4.2                  v1.4.2
```
---
### History
Search all revisions of a release
```bash
## Example for metallb
$ helm history metallb --namespace metallb-system

REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sun Jun 25 00:55:12 2023        superseded      metallb-0.13.10 v0.13.10        Install complete
2               Sun Jun 25 12:29:55 2023        superseded      metallb-0.13.10 v0.13.10        Upgrade complete
3               Sun Jun 25 12:52:05 2023        deployed        metallb-0.13.10 v0.13.10        Upgrade complete
```

Show the values of a specific deployment revision:
```bash
helm get values --revision=3 metallb --namespace metallb-system

USER-SUPPLIED VALUES:
controller:
  nodeSelector:
    node-role.kubernetes.io/metallb-controller: "true"
  tolerations:
  - effect: NoExecute
    key: CriticalAddonsOnly
    operator: Exists
  - effect: NoSchedule
    key: CriticalAddonsOnly
    operator: Exists
loadBalancerClass: metallb
speaker:
  frr:
    enabled: false
```
---
### Search with helm
- `helm search hub` searches the Artifact Hub, which lists helm charts from dozens of different repositories.
- `helm search repo` searches the repositories that you have added to your local helm client (with `helm repo add`). This search is done over local data, and no public network connection is needed.

List all publicaly available wordpress packages:
```bash
helm search hub wordpress
```

Search for all available versions of a particular package
```bash
helm search repo prometheus-community --versions
```

