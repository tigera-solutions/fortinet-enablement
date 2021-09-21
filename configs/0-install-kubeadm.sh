#!/bin/bash
set -e

KUBERNETES_VERSION=1.21.4-00
CALICO_VERSION=3.9.0

# Installing all required packages to run Kubeadm
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install --allow-downgrades -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION 
sudo apt-mark hold kubelet kubeadm kubectl

# Installing Docker CE
sudo curl -fSsl https://get.docker.com | sh
sudo usermod -aG docker ubuntu
newgrp docker

# Installing calicoctl
sudo curl -O -L  https://downloads.tigera.io/ee/binaries/v$CALICO_VERSION/calicoctl && sudo chmod +x calicoctl && sudo mv calicoctl /usr/bin
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config 