#!/bin/bash
set -e

KUBERNETES_VERSION=1.26.3-00
CALICO_VERSION=3.15.2

# Installing all required packages to run Kubeadm
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install --allow-downgrades -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION 
sudo apt-mark hold kubelet kubeadm kubectl

# Installing calicoctl
sudo curl -O -L  https://downloads.tigera.io/ee/binaries/v$CALICO_VERSION/calicoctl && sudo chmod +x calicoctl && sudo mv calicoctl /usr/bin
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config

# configure necessary sysctl settings
sudo modprobe br_netfilter
sudo sysctl net.ipv4.ip_forward=1
sudo sysctl net.bridge.bridge-nf-call-iptables=1
echo "br_netfilter" | sudo tee /etc/modules-load.d/netfilter.conf
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
vm.swappiness=0
vm.overcommit_memory=1
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_keepalive_time=600
EOF

# Configure kubectl autocomplete
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

## Installing Docker CE
#sudo curl -fSsl https://get.docker.com | sh
#sudo usermod -aG docker ubuntu
#newgrp docker

## Install containerd from Docker repo
#sudo apt install -y ca-certificates curl gnupg lsb-release
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
#sudo apt update
#sudo apt install -y containerd.io

# Install containerd
sudo apt install -y containerd

# Configure and restart containerd service
sudo mkdir -p /etc/containerd
if [ -f '/etc/containerd/config.toml' ]; then
  sudo rm /etc/containerd/config.toml
fi
sudo containerd config default | sudo tee /etc/containerd/config.toml
# enable systemd cgroup v2
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/1' /etc/containerd/config.toml
sudo systemctl restart containerd
# get containerd status
sudo systemctl status containerd
# reload systemctl daemon
sudo systemctl daemon-reload
