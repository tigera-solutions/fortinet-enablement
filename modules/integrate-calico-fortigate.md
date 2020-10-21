# Module 8: Integrating Calico Enterprise with FortiGate

Goal: Integrate Calico Enterprise with FortiGate this will enable you to use Calico Enterprise network policy to control traffic from Kubernetes clusters in your FortiGate firewalls.

### How the integration works

The Calico Enterprise integration controller (tigera-firewall-controller) lets you manage FortiGate firewall address group objects dynamically, based on Calico Enterprise GlobalNetworkPolicy.

You determine the Kubernetes pods that you want to allow access outside the firewall, and create Calico Enterprise global network policy using selectors that match those pods. After you deploy the tigera firewall controller in the Kubernetes cluster, you create a ConfigMap with the Fortinet firewall information. The Calico Enterprise controller reads the ConfigMap, gets FortiGate firewall IP address, API token and source IP address selection, it can be either node or pod.

In your kubernetes cluster, if pods IP addresses are routable and address selection is pod, then it populates the Kubernetes pod IPs of selector matching pods in FortiGate address group objects or
If source address selection is node, then populates the kubernetes node IPs of selector matching pods in Fortigate address group objects.

### Steps


1. **Configure FortiGate firewall to communicate with firewall controller.**

a. Determine and note the CIDR’s or IP addresses of all Kubernetes nodes that can run the `tigera-firewall-controller`. This is required to explicitly allow the `tigera-firewall-controller` to access the FortiGate API. In our case, the CIDR is `10.99.0.0/16`

b. Create an `Admin` profile with `read-write` access to `Address and Address Group Objects`. For example: `tigera_api_user_profile`

c. Create a REST API Administrator and associate this user with the `tigera_api_user_profile` profile and add CIDR or IP address of your kubernetes cluster nodes as trusted hosts . For example: `calico_enterprise_api_user`

d. Note the API key.

2. **Configure FortiManager to communicate with firewall controller** 

a. Determine and note the CIDR’s or IP addresses of all Kubernetes nodes that can run the `tigera-firewall-controller`. This is required to explicitly allow the `tigera-firewall-controller` to access the FortiGate API. In our case, the CIDR is `10.99.0.0/16`

b. From system settings, create an `Admin` profile with `Read-Write` access for `Policy & Objects`. For example: `tigera_api_user_profile`

Create a JSON API administrator and associate this user with the `tigera_api_user_profile` profile and add CIDR or IP address of your kubernetes cluster nodes as `Trusted Hosts`.

Note username and password.

3. **Configure Calico Enterprise**

a. From the master node, you will configure Calico Enterprise. You need to fill in your FortiManager and FortiGate PRIVATE IPs in [this](../4-firewall-config.yaml) ConfigMap then apply it. 

```
kind: Namespace
apiVersion: v1
metadata:
  name: tigera-firewall-controller
---
# Configuration of Tigera Firewall Controller
kind: ConfigMap
apiVersion: v1
metadata:
  name: tigera-firewall-controller-configs
  namespace: tigera-firewall-controller
data:
  # FortiGate device information
  tigera.firewall.policy.selector: fortinet
  tigera.firewall.addressSelection: node
  tigera.firewall.fortigate: |
    - name: fortigate
      ip: 10.99.2.100
      apikey: 
        secretKeyRef:
          name: fortigate
          key: apikey-fortigate
  tigera.firewall.fortimgr: |
    - name: fortimanager
      ip: 10.99.2.101
      username: api_user
      adom: root
      password:
        secretKeyRef:
          name: fortimgr
          key: pwd-fortimgr
```

Then you can apply it:

```
$ kubectl apply -f 9-firewall-config.yaml
```

4. **Create FortiGate and FortiManager API User and Key as Kubernetes Secrets.**

a. Store each FortiGate API key as Secret in `tigera-firewall-controller` namespace.
for example, In the above config map for FortiGate device `fortigate`, store its ApiKey as a secret name as fortigate-east1, with key as apikey-fortigate-east1

```
$ kubectl create secret generic fortigate \
-n tigera-firewall-controller \
--from-literal=apikey-fortigate=<fortigate-api-secret>
```

b. Store each FortiManager Password as Secret in `tigera-firewall-controller` namespace.
for example, In the above config map for FortiMgr, store its Password as a secret name as `fortimgr`, with key as `pwd-fortimgr`

```
$ kubectl create secret generic fortimgr \
  -n tigera-firewall-controller \
  --from-literal=pwd-fortimgr=<fortimgr-password>
```

5. Deploy firewall controller in the Kubernetes cluster

a. Install your pull secret

```
kubectl create secret generic tigera-pull-secret \
--from-file=.dockerconfigjson=<path/to/pull/secret> \
--type=kubernetes.io/dockerconfigjson -n tigera-firewall-controller
```

b. Apply the manifest

```
kubectl apply -f https://docs.tigera.io/manifests/fortinet.yaml
```


