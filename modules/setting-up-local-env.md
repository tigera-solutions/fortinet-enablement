# Module 1: Setting up your local environment

**Goal:** We need to make sure your local environment is set up correctly.

## Steps

1. Ensure your Terraform is insatlled correctly. If you do not have it installed, you can install it using the following [link](https://learn.hashicorp.com/tutorials/terraform/install-cli).

    ```
    🐯 → terraform version
    Terraform v0.13.3

    Your version of Terraform is out of date! The latest version
    is 0.13.4. You can update by downloading from https://www.terraform.io/downloads.html
    ```

2. Assuming your SSH public key is named `mykey.pub` and your private SSH key is named `mykey.pem` and the Key Pair name in AWS is named `mykey`. You need to first enable SSH forwarding locally as follows:

    ```
    $  eval `ssh-agent -s`
    $  ssh-add ~/.ssh/mykey.pem 
    ```

    Additionally, you would need to make sure that your SSH client enables forwarding (`ForwardAgent yes`) as follows:

    ```
    🐯 → cat ~/.ssh/config

    HashKnownHosts no
    ForwardAgent yes
    ```

3. Export your AWS Access Key/ID. If you already have them under your `~/.aws/credentials` then you don't need to do this step.

    ```
    $ export AWS_ACCESS_KEY_ID="anaccesskey"
    $ export AWS_SECRET_ACCESS_KEY="asecretkey"
    ```

4. Download this repo into your environment:

    ```
    $ git clone https://github.com/tigera-solutions/fortinet-enablement
    ```

5. Copy the supplied Calico Enterprise license (`license.yaml`) and pull secret (`dockerjsonconfig.json`) into the new directory's `configs` subdirectory.

    ```
    → tree .
    .
    |-- README.md
    |-- configs
    |   |-- 0-install-kubeadm.sh
    |   |-- 1-kubeadm-init-config.yaml
    |   |-- 1-kubeadm-join-config.yaml
    |   |-- 2-ebs-storageclass.yaml
    |   |-- 3-loadbalancer.yaml
    |   |-- 4-firewall-config.yaml
    |   |-- dockerjsonconfig.json
    |   `-- license.yaml
    ```

[Next -> Module 2](../modules/setting-up-aws.md)
