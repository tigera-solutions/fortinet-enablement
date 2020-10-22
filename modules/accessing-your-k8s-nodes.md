# Module 4: Accessing the K8s Nodes

Goal: In this module, you will access the k8s nodes and prep the installation of k8s.

### Steps

1. ssh into the `jumpbox` node using its public IP. This was provided in the terraform output.

2. From the `jumpbox` node, you can now ssh into nodes: `master`, `worker-1`, and `worker-2` using their **private** ip address that was provided in the output of the `terraform apply` step. The username is `ubuntu`.

```
🐯 → ssh ubuntu@34.212.X.X
...

ubuntu@ip-10-99-1-23:~$ ssh ubuntu@10.99.2.212
The authenticity of host '10.99.2.212 (10.99.2.212)' can't be established.
ECDSA key fingerprint is SHA256:PoHtCWs+MkJIxRSlQdNOqg9tkUkvopyWfbuDHw4kA5A.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.99.2.212' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1024-aws x86_64)

...

ubuntu@ip-10-99-2-212:~$ 

```

3. On the `jumpbox` node, there is a script named `/home/calico-fortinet/configs/0-install-kubeadm.sh`. This script will install the following packages: 
    - Docker
    - kubeadm
    - kubectl
    - kubeadm
    - calicoctl
Copy this script to the `master`, `worker-1`, and `worker-2` nodes and run it on **all four nodes** including the `jumphost` node.

```
$ source 0-install-kubeadm.sh
....
$ which kubelet kubectl docker calicoctl kubeadm
/usr/bin/kubelet
/usr/bin/kubectl
/usr/bin/docker
/usr/bin/calicoctl
/usr/bin/kubeadm
```

### NOTE

You will find two directories `configs` and `demo` in the `jumphost` under `/home/calico-fortinet/`. All the configurations needed will be in the `configs` directory and the demo app will be unter the `demo` directory.






