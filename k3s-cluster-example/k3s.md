## Servers used in the scenario
- `172.16.0.70		k3s0.tomspirit.me                     0800270A824A`
- `172.16.0.71		k3s1.tomspirit.me                     080027512F4B`
- `172.16.0.72		k3s2.tomspirit.me                     0800275AC56B`
- `172.16.0.73		k3s3.tomspirit.me                     0800270ED6A0`

Additional A records for the cluster:
- `k3s.tomspirit.me` | The name of the kubernetes cluster
- `k3s-longhorn.tomspirit.me` | For Longhorn
- `k3s-grafana.tomspirit.me` | For grafana 
- `k3s-wp.tomspirit.me` | For the wordpress deployment

## On all servers 

If **Ubuntu**
```bash
sudo ufw disable 
sudo mkdir /local-path-provisioner

sudo apt install open-iscsi
sudo apt install -y nfs-common jq
```
<br>

If **Alpine** Linux
```bash
# Set hostnames respectively
hostname k3s3.tomspirit.me
echo k3s3.tomspirit.me >/etc/hostname

# Update the hostname
vi /etc/hosts

apk add open-iscsi nfs-utils
rc-update add nfs && rc-service nfs start

# For Longhorn
apk add curl findmnt lsblk parted htop
```
<br>

For **Alpine** Linux shared(slave) mounts need to be enabled otherwise some deployments will fail:
###### https://ixday.github.io/post/shared_mount/
```bash
# Enable this at runtime
mount --make-rshared /

# Enable at boot time every time
install -D -m 0755 /dev/stderr /etc/local.d/10-mount.start 2<<-EOF
#!/bin/sh
mount --make-rshared /
EOF

rc-update add local default
```
<br>


## Master Node

### Provision the K3s Master
K3s by default automatically deployes`traefik` as ingress controler. In the bellow command I'm disabling traefik becaue I want to use `nginx-ingress` instead. Additonally `metrics-server` is being disabled because the the helm deployment of `kube-prometheus-stack` includes the metrics server with it.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.12+k3s1 sh -s - server \
--cluster-init \
--default-local-storage-path /local-path-provisioner \
--node-taint CriticalAddonsOnly=true:NoExecute \
--node-taint CriticalAddonsOnly=true:NoSchedule \
--tls-san 172.16.0.70 \
--tls-san 172.16.0.71 \
--tls-san 172.16.0.72 \
--tls-san 172.16.0.73 \
--tls-san k3s.tomspirit.me \
--tls-san k3s0.tomspirit.me \
--disable traefik,metrics-server

# Get the node-token and set the kubeconfig to be readable for everyone
sudo cat /var/lib/rancher/k3s/server/node-token 
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```
<br>

## Worker Nodes

Prepare the nodes and mount the partition into `/longhorn`
```bash
# Format and mount the aditional disk
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i sd
parted /dev/sdc --script mklabel gpt mkpart ext4part ext4 0% 100%
mkfs.ext4 /dev/sdc1
partprobe /dev/sdc1

mkdir /longhorn
mkdir /local-storage-provisioner
mount /dev/sdb1 /longhorn

# Get the partid
blkid

vim /etc/fstab
UUID=bdea8d4f-fa81-4702-9516-6d462cdb4c3e	/longhorn	ext4	defaults,nofail		1	2
```

### Install K3s Workers 
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.12+k3s1 \
K3S_URL=https://k3s.tomspirit.me:6443 \
K3S_TOKEN=K108b8b2ff5578e57ff7ea0b2a57fe43055043d9576f3ce7c377f0e29803a2d2501::server:6ad2ada988a389acf01e399e88344fee \
sh -
```

#### Check the cluster after the installation
There is a default kubectl config file inti `/etc/rancher/k3s/k3s.yaml` on the master node. Copy and use this file from your own PC.
```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```
<br>

## Install cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.0
```

## Deploy nginx ingress controler
Do this from an external shel using helm
```bash
# nginx ingress 
# https://kubernetes.github.io/ingress-nginx/deploy/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo update
helm search repo ingress-nginx --versions

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.6.1 \
  --set controller.ingressClass=nginx \
  --set controller.ingressClassResource.default=true \
  --set controller.service.type=LoadBalancer \
  --set controller.admissionWebhooks.certManager.enable=true \
  --set controller.metrics.enabled=true \
  --set controller.metrics.prometheusRule.enabled=true
```
<br>

## [Optional] Deploy Rancher
###### https://ranchermanager.docs.rancher.com/getting-started/quick-start-guides/deploy-rancher-manager/helm-cli

Prepare the cluster. Add the helm repos, create namespaces.
```bash
# Add the rancher helm repo (I'm using stable in this case)
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
kubectl create namespace cattle-system
helm repo update
```

Install Rancher.<br>
Make sure to update the values accordingly
```bash
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.tomspirit.me \
  --set replicas=1 \
  --set bootstrapPassword=25.8069
```
<br>

## Deploy Prometheus monitoring
**NOTE:** If Rancher is deployed this can be done via Rancher's interface

###### https://github.com/prometheus-community/helm-charts/tree/kube-prometheus-stack-16.0.1/charts/kube-prometheus-stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo update 

helm install kube-prometheus-stack \
  -f values-kube-prometheus-stack.yaml \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --version 46.8.0 
```

### [OBSOLETE] Grafana ingress
An ingress is being added automatically via `values-kube-prometheus-stack.yaml` so the bellow snippet is just an example.

In order to access the grafana you need to expose it via an nginx ingress.<br>
Create `grafana-ingress.yml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kube-prometheus-stack-grafana-ingress
  namespace: monitoring
  annotations:
    # prevent the controller from redirecting (308) to HTTPS
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
    # custom max body size for file uploading like backing image uploading
    nginx.ingress.kubernetes.io/proxy-body-size: 10000m
spec:
  ingressClassName: nginx
  rules:
  - host: "k3s-grafana.tomspirit.me"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: kube-prometheus-stack-grafana
            port:
              number: 80
```

Deploy the ingress
```bash
kubectl -n monitoring apply -f grafana-ingress.yml
```
<br>

## Longhorn storage
**NOTE:** If Rancher is deployed this can be done via Rancher's interface

###### https://longhorn.io/docs/1.4.2/deploy/install/
```bash
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/scripts/environment_check.sh | bash 
helm repo add longhorn https://charts.longhorn.io 
helm repo update
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system --create-namespace \
  --version 1.4.2 
```

### Create ingress for the longhorn frontend
**WARNING:** High security implications. Do this only if you know and understand the risks.

###### https://longhorn.io/docs/1.4.2/deploy/accessing-the-ui/longhorn-ingress/
```bash
#Create a basic auth file auth
USER=admin; PASSWORD=admin; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth

# Create a secret:
kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
```

### Create an Ingress manifest longhorn-ingress.yml
```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
    # type of authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    # prevent the controller from redirecting (308) to HTTPS
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
    # name of the secret that contains the user/password definitions
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropriate context why the authentication is required
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required '
    # custom max body size for file uploading like backing image uploading
    nginx.ingress.kubernetes.io/proxy-body-size: 10000m
spec:
  ingressClassName: nginx
  rules:
  - host: "k3s-longhorn.tomspirit.me"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: longhorn-frontend
            port:
              number: 80
```
Deploy the ingress
```bash
kubectl -n longhorn-system apply -f longhorn-ingress.yml
```