# Module 4: Accessing the K8s Nodes

Goal: In this module, you will access the k8s nodes and prep the installation of k8s.

## Steps

1. SSH into the `master` node using its public IP. This was provided in the terraform output.

2. From the `master` node, you can now ssh into nodes:  `worker-1`, and `worker-2` using their **private** ip address that was provided in the output of the `terraform apply` step. The username is `ubuntu`.

    ```text
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

3. On the `master` node, there is a script named `0-install-kubeadm.sh` under the`/home/ubuntu/calico-fortinet` directory. This script installs the following packages:

    - containerd
    - kubeadm
    - kubectl
    - kubeadm
    - calicoctl

4. Copy the script file to `worker-1` and `worker-2` nodes, and run it on **all three nodes** including the `master`.

    a. On `master` node go to `calico-fortinet` directory and set `exec` permission for the script.

    ```bash
    cd calico-fortinet
    chmod u+x 0-install-kubeadm.sh
    ```

    b. Copy the script to `worker-1` and `worker-2` and set `exec` permisson for the script on each node.

    >If you don't have SSH Forwarding configured, you'll need to provide SSH private key via `-i /path/to/key` option.

    ```bash
    scp 0-install-kubeadm.sh ubuntu@<WOERKER-1_IP>:/home/ubuntu
    scp 0-install-kubeadm.sh ubuntu@<WOERKER-2_IP>:/home/ubuntu
    ```

    c. Run the script on all the nodes you copied it to.

    ```bash
    source ./0-install-kubeadm.sh
    ```

    d. Verify that all necessary components were installed.

    ```bash
    $ which kubelet kubectl containerd calicoctl kubeadm
    
    /usr/bin/kubelet
    /usr/bin/kubectl
    /usr/bin/containerd
    /usr/bin/calicoctl
    /usr/bin/kubeadm
    ```

5. There is also another kubeadm configuration named `1-kubeadm-join-config.yaml` under the same directory. Copy it to the two worker nodes:

    >If you don't have SSH Forwarding configured, you'll need to provide SSH private key via `-i /path/to/key` option.

    ```bash
    scp 1-kubeadm-join-config.yaml ubuntu@<WOERKER-1_IP>:/home/ubuntu
    scp 1-kubeadm-join-config.yaml ubuntu@<WOERKER-2_IP>:/home/ubuntu
    ```

[Module 3 :arrow_left:](../modules/configuring-fortigate-to-allow-internet.md) &nbsp;&nbsp;&nbsp;&nbsp;[:arrow_right: Module 5](../modules/creating-your-k8s-cluster.md)

[:leftwards_arrow_with_hook: Back to Main](/README.md)
