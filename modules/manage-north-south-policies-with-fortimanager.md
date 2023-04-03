# Module 11: Manage North-South policies with FortiManager

>**THIS MODULE IS NOT READY YET.** PLEASE SKIP TO [MODULE 12](../modules/integrate-calico-with-fortimanager.md).

**Goal:** Once FortiGate is integrated with FortiManager, all policies can be managed from within a single user interface - FortiManager. We are now ready to verify the integration by creating and managing the policies in FortiManager UI.

## Steps

1. Configure FortiManager to communicate with firewall controller

    a. Determine and note the CIDR’s or IP addresses of all Kubernetes nodes that can run the `tigera-firewall-controller`. This is required to explicitly allow the `tigera-firewall-controller` to access the FortiGate API. In our case, the CIDR is `10.99.0.0/16`

    b.  Go to FortiManager from your browser, from **System Settings** -> **Profile**, create a new  profile named `tigera_api_user_profile` with `Read-Write` access for `Policy & Objects`.

    ![fortimanager_user_profile1.png](../img/fortimanager_user_profile1.png)

    ![fortimanager_user_profile1.png](../img/fortimanager_user_profile2.png)

    c. Under **Administrators** tab, create a new user named `tigera_ns_fortimanager_admin` and associate this user with the `tigera_api_user_profile` profile. Specify a policy package that you are going to use to manage North-South policies for Calico Enterprise integration and assign **Read-Write** permisison in the JSON API Access setting. If you intend to manage only North-South policies in FortiManager, you can choose  **All Packages** option for `Policy Package Access` setting. Enable `Trusted Hosts` field and provide CIDR for Kubernetes nodes. In our case, it is `10.99.0.0/16`.

    ![fortimanager_create_user_ns.png](../img/fortimanager_create_user_ns.png)

    d. Note username (`tigera_fortimanager_admin`) and password you used.

2. Configure Calico Enterprise connection to FortiManager

    a. Configure secret `fortimgr-ns` with password for FortiManager API user `tigera_ns_fortimanager_admin`.

    ```bash
    kubectl create secret generic fortimgr-ns -n tigera-firewall-controller --from-literal=fortimgr-pwd=<fortimanager-api-user-password>
    ```

    b. From the master node, you will configure Calico Enterprise. You need to uncomment FortiManager related configuration and fill in your FortiManager **Private IP** from the `10.99.1.X` subnet, user name (`tigera_ns_fortimanager_admin`) and password in the `4-fortigate-firewall-config.yaml` ConfigMap then apply it.

    ```bash
    kubectl create -f 4-fortigate-firewall-config.yaml
    ```

3. Import FortiGate policy into FortiManager

    >This step is only necessary if you skipped object import while integrating FortiGate and FortiManager in previous module. If the import was already completed, skip this step.

    - In order to preserve any policies configured in FortiGate, we need to import FortiGate policies into FortiManager.
    - Once FortiGate policies are imported into FortiManager, from now on you can manage all North-South policies in FortiManager and push the package with the policies to FortiGate devices.

[Module 10 :arrow_left:](../modules/integrate-fortigate-fortimanager.md) &nbsp;&nbsp;&nbsp;&nbsp;[:arrow_right: Module 12](../modules/integrate-calico-with-fortimanager.md)

[:leftwards_arrow_with_hook: Back to Main](/README.md)
