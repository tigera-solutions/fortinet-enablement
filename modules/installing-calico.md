# Module 7: Installing Calico Enterprise

**Goal:** Install and Configure Calico Enterprise on your K8s Cluster.

## Steps

Now it's time to install Calico Enterprise on this cluster. We will be following [these](https://docs.tigera.io/calico-enterprise/latest/getting-started/install-on-clusters/kubernetes/generic-install) steps.

1. The first step is to set up cloud storage for Calico Enterprise.

    Since we're running on AWS and using a self-managed **kubeadm** cluster, we need to configure [AWS EBS CSI driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md) for the cluster.

    ```bash
    # configure aws-secret to allow CIS driver access EBS storage
    kubectl create secret generic aws-secret \
    --namespace kube-system \
    --from-literal "key_id=${AWS_ACCESS_KEY_ID}" \
    --from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"

    # install CSI driver
    kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.17"
    ```

    Then we can use the `2-ebs-storageclass.yaml` EBS Storage Class config. On the master node to configure the `storageClass` resource:

    ```bash
    $ cat 2-ebs-storageclass.yaml

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: tigera-elasticsearch
    provisioner: ebs.csi.aws.com
    reclaimPolicy: Retain
    allowVolumeExpansion: true
    volumeBindingMode: WaitForFirstConsumer
    ```

    Use `2-ebs-storageclass.yaml` file to apply `tigera-elasticsearch` StorageClass resource.

    ```bash
    kubectl create -f 2-ebs-storageclass.yaml
    ```

2. Now we can create the Tigera and Prometheus operators that will create the proper CRDs, RBAC, services needed for Calico Enterprise.

    ```bash
    kubectl create -f https://downloads.tigera.io/ee/v3.15.3/manifests/tigera-operator.yaml
    kubectl create -f https://downloads.tigera.io/ee/v3.15.3/manifests/tigera-prometheus-operator.yaml
    ```

3. In order to install Calico Enterprise, you need a pull secret to be able to pull the images and a license key. In this step we will install the `dockerjsonconfig` as a pull secret. This file and the trial license key were provided to you previously and were copied to the `/home/ubuntu/calico-fortinet` directory.

    ```bash
    # run this command from within /calico-fortinet path
    kubectl create secret generic tigera-pull-secret \
        --type=kubernetes.io/dockerconfigjson -n tigera-operator \
        --from-file=.dockerconfigjson=dockerjsonconfig.json
    ```

4. Download the Tigera Custom Resources manifest, adjust podNetwork setting to use IP CIDR configured for the kubeadm cluster, then watch `tigerastatus` resource to make sure the API server is `available` before moving to the next step.

    ```bash
    curl -s https://downloads.tigera.io/ee/v3.15.3/manifests/custom-resources.yaml | sed -e '/  # registry:.*$/a \
      calicoNetwork:\
        bgp: Disabled\
        nodeAddressAutodetectionV4:\
        ipPools: [{cidr: "172.16.0.0\/16",natOutgoing: "Enabled",encapsulation: "VXLAN"}]\
    ' | kubectl apply -f-
    ```

    Watch `apiserver` component to become available before proceeding.

    ```bash
    $ watch kubectl get tigerastatus

    NAME                  AVAILABLE   PROGRESSING   DEGRADED   SINCE
    apiserver             True        False         False      27s
    calico                True        False         False      87s
    compliance                                      True       
    intrusion-detection                             True       
    log-collector                                   True       
    log-storage                                     True       
    manager                                         True       
    monitor               True        False         False      57s

    ```

5. Configure Calico Enterprise license as follows ( assumes you saved your trial license as `license.yaml`)

    ```bash
    # run this command from within /calico-fortinet path
    kubectl create -f license.yaml
    ```

6. Finally, watch `tigerastatus` resource to ensure that the `apiserver`,`calico`, `log-storage`, and `manager` components of Calico Enterprise report their availability status as `True`. This would mean that the Calico CNI and the enterprise components work as expected. This step may take some time...

    ```bash
    $ watch kubectl get tigerastatus

    NAME                  AVAILABLE   PROGRESSING   DEGRADED   SINCE
    apiserver             True        False         False      4m27s
    calico                True        False         False      5m27s
    compliance            True        False         False      22s
    intrusion-detection   True        False         False      27s
    log-collector         True        False         False      22s
    log-storage           True        False         False      22s
    manager               True        False         False      2s
    monitor               True        False         False      4m57s
    ```

7. It's time now to expose Calico Enterprise UI externally using the `03-loadbalancer.yaml` `LoadBalancer` service. It will automatically created an AWS ELB to front Calico Enterprise using a public IP.

    ```text
    $ cat 3-loadbalancer.yaml

    kind: Service
    apiVersion: v1
    metadata:
      name: tigera-manager-external
      namespace: tigera-manager
    spec:
      type: LoadBalancer
      selector:
        k8s-app: tigera-manager
      externalTrafficPolicy: Local
      ports:
      - port: 443
        targetPort: 9443
        protocol: TCP
    ```

    Deploy the LoadBalancer service to expose Enterprise Manager UI.

    ```bash
    kubectl create -f 3-loadbalancer.yaml
    ```

    After creating the service, it may take a few minutes for the load balancer to be created. Once complete, the load balancer IP address will appear as an `ExternalIP` in `kubectl get services -n tigera-manager tigera-manager-external`.

    ```text
    $ kubectl get services -n tigera-manager tigera-manager-external

    NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)         AGE
    tigera-manager-external   LoadBalancer   192.168.200.55   a86f00fcae2d44exxxxx.us-west-2.elb.amazonaws.com   443:31236/TCP   20h
    ```

8. We need to create a user account to be able to log into Calico Enterprise and retrieve the access token to be able to log into the Kibana dashboard.

    ```bash
    # Creating a Calico Enterprise User called admin and its associated k8s Service Account
    kubectl create sa admin -n default
    kubectl create clusterrolebinding admin-access --clusterrole tigera-network-admin --serviceaccount default:admin
    kubectl create token admin --duration=24h

    # Get the Kibana Login (Username is **elastic**)
    export elasticToken=$(kubectl get -n tigera-elasticsearch secret tigera-secure-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

    echo $elasticToken
    ```

    Keep track of these two tokens as they will be used later on!

9. Finally, you can login to the Calico Enterprise UI using the loadbalancer and user auth token provided above.

    >It can take a moment for the load balancer URL to become operational as AWS needs to pass a few checks on its side to enable traffic to the load balancer.

    ![img](../img/tigera-ui.png)

10. If the URL is not loading after some time. Check if the `tigera-manager` pod is running on the `master` node.  If it is, go ahead and delete the pod so it can be rescheduled on another node. The reason this issue is seen is that the ELB doesn't forward to pods deployed on the `master` node since it's on the public subnet.

    ```text
    $ kubectl get pod -n tigera-manager -o wide

    NAME                             READY   STATUS    RESTARTS   AGE   IP              NODE                                        NOMINATED NODE   READINESS GATES
    tigera-manager-76b568d7c-4rcbt   3/3     Running   0          10h   172.16.46.134   ip-10-99-2-239.us-west-2.compute.internal   <none>           <none>

    $ kubectl delete pod -l k8s-app=tigera-manager -n tigera-manager
    ```

11. _[Optional]_ Tune Felix component settings

    >Felix is one of the Calico components through which one can tune various configuration parameters.

    Let's adjust flow logs flushing interval, aggregation and TCP stats settings.

    ```bash
    kubectl patch felixconfiguration.p default -p '{"spec":{"flowLogsFlushInterval":"10s"}}'
    kubectl patch felixconfiguration.p default -p '{"spec":{"flowLogsFileAggregationKindForAllowed":1}}'
    kubectl patch felixconfiguration.p default -p '{"spec":{"dnsLogsFlushInterval":"10s"}}'
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"flowLogsCollectTcpStats":true}}'
    ```

[Module 6 :arrow_left:](../modules/join-nodes.md) &nbsp;&nbsp;&nbsp;&nbsp;[:arrow_right: Module 8](../modules/integrate-calico-fortigate.md)

[:leftwards_arrow_with_hook: Back to Main](/README.md)
