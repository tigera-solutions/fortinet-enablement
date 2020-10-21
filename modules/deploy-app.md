# Module 9: Running a Sample Application 

Goal: We are now ready to verify the integration by launching an application and scaling its pods to ensure that the pods' IPs are automatically populated in FortiGate.


## Steps


1. Under the `demo` subdirectory, there is a `tiers-demo.yaml` and `storefront-demo.yaml` deployment files. Let's take a look at the `tiers-demo.yaml`:


```
apiVersion: projectcalico.org/v3
kind: Tier
metadata:
  name: fortinet
spec:
  order: 800
---
apiVersion: projectcalico.org/v3
kind: Tier
metadata:
  name: platform
spec:
  order: 700
---
apiVersion: projectcalico.org/v3
kind: Tier
metadata:
  name: security
spec:
  order: 500
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: fortinet.pass
spec:
  tier: fortinet
  order: 300
  selector: ''
  namespaceSelector: ''
  serviceAccountSelector: ''
  ingress:
    - action: Pass
      source: {}
      destination: {}
  egress:
    - action: Pass
      source: {}
      destination: {}
  doNotTrack: false
  applyOnForward: false
  preDNAT: false
  types:
    - Ingress
    - Egress
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: platform.pass
spec:
  tier: platform
  order: 300
  selector: ''
  namespaceSelector: ''
  serviceAccountSelector: ''
  ingress:
    - action: Pass
      source: {}
      destination: {}
  egress:
    - action: Pass
      source: {}
      destination: {}
  doNotTrack: false
  applyOnForward: false
  preDNAT: false
  types:
    - Ingress
    - Egress
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: security.pass
spec:
  tier: security
  order: 300
  selector: ''
  namespaceSelector: ''
  serviceAccountSelector: ''
  ingress:
    - action: Pass
      source: {}
      destination: {}
  egress:
    - action: Pass
      source: {}
      destination: {}
  doNotTrack: false
  applyOnForward: false
  preDNAT: false
  types:
    - Ingress
    - Egress
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: fortinet.storefront-fortigate
spec:
  selector: "app == 'microservice2'"
  types:
  - Egress
  egress:
  - action: Allow
```

This deployment creates the necessary Calico Enterprise Tiers , one of which is the `fortinet` Tier. This tier is the one that we have configured in the previous module to associate all policies under it with a FortiGate Address group. There are also other tiers like `security` and `platform` that are used for demonstrative purposes. Finally, the last part of it is the `GlobalNetworkPolicy` that maps out the application labels to Fortigate address group. In our example, this configuration will create a Fortigate Address group named `storefront-fortigate` that automatically detects and populate the node IPs of any pod with label `app == 'microservice2'`

2. You can copy these two YAML files into your master nodes and deploy them:

```
$ kubectl apply -f tiers-demo.yaml 
$ kubectl apply -f storefront-demo.yaml
```

3. In the FortiGate portal, navigate to **Policy & Objects > Addresses**. Once the application is deployed, you should see that an **storefront-fortigate** address group is created and the respective Node IPs are associated with it.

