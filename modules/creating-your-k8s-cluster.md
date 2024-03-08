# Module 5: Creating your Kubernetes Cluster using kubeadm

**Goal:** In this module, you will set up a Kubernetes cluster using `kubeadm`.

## Steps

Before going through this module, we need to make sure we have planned our kubernetes network IP ranges. We need to have an IP range for the pods and an IP range for services. For the sake of this lab we will be using the following:

```bash
POD CIDR == 172.16.0.0/16
SERVICE CIDR == 192.168.0.0/16
```

>You will find some configuration files and `demo` directory on the `master` node under `/home/calico-fortinet/` directory. All the configurations needed are in this directory and the demo app is under the `demo` directory. 

```text
|-- configs
|   |-- 0-install-kubeadm.sh
|   |-- 1-kubeadm-init-config.yaml
|   |-- 1-kubeadm-join-config.yaml
|   |-- 2-ebs-storageclass.yaml
|   |-- 3-loadbalancer.yaml
|   |-- 4-firewall-config.yaml
|   |-- dockerjsonconfig.json
|   `-- license.yaml
|-- demo
|   |-- storefront-demo.yaml
|   `-- tiers-demo.yaml
```

1. SSH into the `master` node, then update the `1-kubeadm-init-config.yaml` to add the FQDN of the master node(e.g `ip-10-99-2-246.us-west-2.compute.internal`). You can get it using `$ hostname -f`. Now you can create a new cluster configuration file based on this config.

    a. Check node's hostname.

    ```bash
    $ hostname -f

    ip-10-99-1-X.us-west-2.compute.internal
    ```

    b. Configure node's hostname in `1-kubeadm-init-config.yaml` configuration file.

    ```bash
    K8S_VERSION=$(kubeadm version -oshort)
    sed -i "s/name:\ master/name:\ $(hostname -f)/1; s/kubernetesVersion:.*$/kubernetesVersion: ${K8S_VERSION}/1" 1-kubeadm-init-config.yaml
    ```

    Example configuration:

    ```bash
    $ cat 1-kubeadm-init-config.yaml

    apiVersion: kubeadm.k8s.io/v1beta3
    bootstrapTokens:
    - groups:
      - system:bootstrappers:kubeadm:default-node-token
      token: abcdef.0123456789abcdef
      ttl: 24h0m0s
      usages:
      - signing
      - authentication
    kind: InitConfiguration
    localAPIEndpoint:
      bindPort: 6443
    nodeRegistration:
      criSocket: unix:///var/run/containerd/containerd.sock
      imagePullPolicy: IfNotPresent
      kubeletExtraArgs:
        cloud-provider: aws
        feature-gates: EphemeralContainers=true
      name: ip-10-99-1-X.us-west-2.compute.internal               # UPDATE with the full AWS DNS name e.g ip-10-99-2-246.us-west-2.compute.internal
      taints:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
    ---
    apiServer:
      extraArgs:
        cloud-provider: aws
        feature-gates: EphemeralContainers=true
      timeoutForControlPlane: 4m0s
    apiVersion: kubeadm.k8s.io/v1beta3
    certificatesDir: /etc/kubernetes/pki
    clusterName: kubernetes
    controllerManager:
      extraArgs:
        cloud-provider: aws
        configure-cloud-routes: "false"
        feature-gates: EphemeralContainers=true
    dns: {}
    etcd:
      local:
        dataDir: /var/lib/etcd
    imageRepository: registry.k8s.io
    kind: ClusterConfiguration
    kubernetesVersion: v1.26.3
    networking:
      dnsDomain: cluster.local
      podSubnet: 172.16.0.0/16
      serviceSubnet: 192.168.0.0/16
    scheduler:
      extraArgs:
        feature-gates: EphemeralContainers=true
    ```

2. Pre-pull necessary images on the each node

    ```bash
    sudo kubeadm config images pull
    ```

3. Now you can launch Kubernetes using `kubeadm` (on the `master` node)

    ```bash
    $ sudo kubeadm init --config 1-kubeadm-init-config.yaml

    [init] Using Kubernetes version: v1.26.3
    [preflight] Running pre-flight checks
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [ip-10-99-1-153.us-west-2.compute.internal kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [192.168.0.1 10.99.1.153]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [ip-10-99-1-153.us-west-2.compute.internal localhost] and IPs [10.99.1.153 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [ip-10-99-1-153.us-west-2.compute.internal localhost] and IPs [10.99.1.153 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    [apiclient] All control plane components are healthy after 7.004613 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node ip-10-99-1-153.us-west-2.compute.internal as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    [mark-control-plane] Marking the node ip-10-99-1-153.us-west-2.compute.internal as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    [bootstrap-token] Using token: abcdef.0123456789abcdef
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    [addons] Applied essential addon: CoreDNS
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Alternatively, if you are the root user, you can run:

      export KUBECONFIG=/etc/kubernetes/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      https://kubernetes.io/docs/concepts/cluster-administration/addons/

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 10.99.1.153:6443 --token abcdef.0123456789abcdef \
            --discovery-token-ca-cert-hash sha256:9643ff1758f9b5741bb7153f136717a9aeaf36a862fa7e7bb073a82238cdab3f
    ```

    Note the `sha256` hash value as you will need it when joining the worker nodes to the cluster.

3. Make sure you follow the below steps to setup `kubectl` and note the `kubeadm join` command that was provided.

    ```bash
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```

4. Verify that you can issue `kubectl` commands. The `master` node will be in the `NotReady` state until Calico us deployed.

    ```bash
    $ kubectl get nodes

    NAME                                        STATUS   ROLES    AGE   VERSION
    ip-10-99-1-153.us-west-2.compute.internal   NotReady    master   10m   v1.26.3
    ```

5. Collect settings to join worker nodes.

    Get join token and certificate hash value to use when joining worker nodes to the cluster.

    >These commands provided as an example to get join token and certificate hash. Alternatively, you can copy this information from the output in step 2.

    ```bash
    # set vars
    JOIN_TOKEN=$(kubeadm token list -o jsonpath='{.token}')
    CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
    CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
    # print vars
    echo -e "JOIN_TOKEN=$JOIN_TOKEN \nCERT_SHA=sha256:$CERT_HASH \nCONTROL_PLANE_IP=$CONTROL_PLANE_IP"
    ```

[Module 4 :arrow_left:](../modules/accessing-your-k8s-nodes.md) &nbsp;&nbsp;&nbsp;&nbsp;[:arrow_right: Module 6](../modules/join-nodes.md)

[:leftwards_arrow_with_hook: Back to Main](/README.md)
