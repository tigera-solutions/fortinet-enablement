# Module 6: Joining Worker Nodes to the Cluster

**Goal:** Joining the other two worker nodes to the cluster.

1. We need to join the other nodes. For every worker node, ssh into the node and update the `1-kubeadm-join-config.yaml` file that we copied to `/home/ubuntu` with the node details. You need to update the following for every worker node.

    - `apiServerEndpoint`  to reflect MASTER PRIVATE IP  
    - `caCertHashes` to reflect the SHA hash of the CA. This was provided in the output of the `kubeadm init` step that you've done previously.  
    - `name` to reflect the full hostname of the node (e.g `ip-10-99-2-177.us-west-2.compute.internal`)

    ```
      ---
      apiVersion: kubeadm.k8s.io/v1beta2
      kind: JoinConfiguration
      discovery:
      bootstrapToken:
          token: abcdef.0123456789abcdef                   
          apiServerEndpoint: "MASTER_PRIVATE_IP:6443"      # UPDATE to reflect MASTER PRIVATE IP
          caCertHashes: ["sha256:2a78c74c95db246c9d711276d1d0c9956cd36e765a1181519ab0f03a037488b6"]  # UPDATE based on kubeadm init output
      nodeRegistration:
      name: ip-10-99-2-X.us-west-2.compute.internal    # UPDATE with Full Hostname of Local Worker Node
      kubeletExtraArgs:
          cloud-provider: aws
    ```

2. Using the updated join configuration file, you can now join each of the nodes as follows:

    ```
    $ sudo kubeadm join --config=1-kubeadm-join-config.yaml
    [preflight] Running pre-flight checks
          [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    [preflight] Reading configuration from the cluster...
    [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Starting the kubelet
    [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

    This node has joined the cluster:
    * Certificate signing request was sent to apiserver and a response was received.
    * The Kubelet was informed of the new secure connection details.

    Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
    ```

3. Verify that you have successfully joined the nodes to the cluster. On your `master` node:

    ```
    $ kubectl get nodes
    NAME           STATUS     ROLES    AGE     VERSION
    ip-10-99-2-11.us-west-2.compute.internal   NotReady   <none>   2m13s   v1.19.2
    ip-10-99-2-22.us-west-2.compute.internal  NotReady   <none>   2m12s   v1.19.2
    ip-10-99-2-54.us-west-2.compute.internal        NotReady   master   16m     v1.19.2
    ```

[Next -> Module 7](./modules/installing-calico.md)
