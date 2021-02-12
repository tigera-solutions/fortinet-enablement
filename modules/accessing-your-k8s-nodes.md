# Module 4: Accessing the K8s Nodes

Goal: In this module, you will access the k8s nodes and prep the installation of k8s.

## Steps

1. SSH into the `master` node using its public IP. This was provided in the terraform output.

2. From the `master` node, you can now ssh into nodes:  `worker-1`, and `worker-2` using their **private** ip address that was provided in the output of the `terraform apply` step. The username is `ubuntu`.

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

3. On the `master` node, there is a script named `0-install-kubeadm.sh` under the`/home/calico-fortinet` directory. This script will install the following packages:

    - Docker
    - kubeadm
    - kubectl
    - kubeadm
    - calicoctl

4. Copy the script file to the  `worker-1`, and `worker-2` nodes and run it on **all three nodes** including the `master`

    ```
    $ scp 0-install-kubeadm.sh ubuntu@<WOERKER-1_IP>:/home/ubuntu
    $ scp 0-install-kubeadm.sh ubuntu@<WOERKER-2_IP>:/home/ubuntu
    ...
    $ source /home/ubuntu/0-install-kubeadm.sh
    ....
    $ which kubelet kubectl docker calicoctl kubeadm
    /usr/bin/kubelet
    /usr/bin/kubectl
    /usr/bin/docker
    /usr/bin/calicoctl
    /usr/bin/kubeadm
    ```

5. There is also another kubeadm configuration named `1-kubeadm-join-config.yaml` under the same directory. Copy it to the two worker nodes:

    ```
    $ scp 1-kubeadm-join-config.yaml ubuntu@<WOERKER-1_IP>:/home/ubuntu
    $ scp 1-kubeadm-join-config.yaml ubuntu@<WOERKER-2_IP>:/home/ubuntu
    ```

[Next -> Module 5](../modules/creating-your-k8s-cluster.md)
