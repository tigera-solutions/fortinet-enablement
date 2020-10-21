#!/bin/bash
set -e

# Installing all required packages to run Kubeadm
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Installing Docker CE
sudo curl -fSsl https://get.docker.com | sh
sudo usermod -aG docker ubuntu

# Installing calicoctl
sudo curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.16.1/calicoctl && sudo chmod +x calicoctl && sudo mv calicoctl /usr/bin
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config 


