#!/bin/bash
set -e

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