# Module 4: Accessing the K8s Nodes

Goal: In this module, you will access the k8s nodes and prep the installation of k8s.

### Steps

1. ssh into the `jumpbox` node using its public IP. This was provided in the terraform output.

2. From the `jumpbox` node, you can now ssh into nodes: `master`, `worker-1`, and `worker-2` using their **private** ip address that was provided in the output of the `terraform apply` step. The username is `ubuntu`.

3. On the `jumpbox` node, there is a script named `/home/calico-fortinet/configs/0-install-kubeadm.sh`. Copy this script to the `master`, `worker-1`, and `worker-2` nodes and run it on **all four nodes** including the `jumphost` node.

### NOTE

You will find two directories `configs` and `demo` in the `jumphost` under `/home/calico-fortinet/`. All the configurations needed will be in the `configs` directory and the demo app will be unter the `demo` directory.






