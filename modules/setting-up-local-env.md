# Module 1: Setting up your local environment

**Goal:** We need to make sure your local environment is set up correctly.

## Choose between local environment and Cloud9 instance

The simplest ways to configure your working environment is to either use your local environment, i.e. laptop, desktop computer, etc., or create an [AWS Cloud9 environment](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html) from which you can execute all the required commands in this workshop. If you're familiar with tools like `SSH client`, `terraforrm`, and feel comfortable using your local shell, then go to the next section.

To configure a Cloud9 instance, open AWS Console and navigate to Services > Cloud9. Create environment in the desired region. You can use all the default settings when creating the environment, but consider using `t3.small` instance as the `t2.micro` instance could be a bit slow. It usually takes only a few minutes to get the Cloud9 instance setup.

## Steps

1. Ensure your Terraform is installed correctly. If you do not have it installed, you can install it using the following [link](https://learn.hashicorp.com/tutorials/terraform/install-cli).

    ```bash
    🐯 → terraform version
    
    Terraform v0.14.5

    Your version of Terraform is out of date! The latest version
    is 0.14.7. You can update by downloading from https://www.terraform.io/downloads.html
    ```

2. Assuming your SSH public key is named `mykey.pub` and your private SSH key is named `mykey.pem` and the Key Pair name in AWS is named `mykey`. You need to first enable SSH forwarding locally as follows:

    ```bash
    eval `ssh-agent -s`
    # make sure the key has appropriate permission set
    chmod 400 ~/.ssh/mykey.pem
    ssh-add ~/.ssh/mykey.pem 
    ```

    >If you don't have AWS Key Pair created, you can either [create a new key pair or import existing key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#prepare-key-pair) into AWS.

    Additionally, you would need to make sure that your SSH client enables forwarding, i.e. `ForwardAgent yes`. You can check it by running the following command:

    ```bash
    # check SSH configuration options in your environment
    🐯 → cat ~/.ssh/config

    HashKnownHosts no
    ForwardAgent yes
    ```

    If you don't have `~/.ssh/config` in your environment, you can create it and set the required options:

    ```bash
    # create SSH config file and set configuration options
    cat > ~/.ssh/config << EOF
    HashKnownHosts no
    ForwardAgent yes
    EOF
    ```

    Set `600` permission for the `~/.ssh/config`

    ```bash
    chmod 600 ~/.ssh/config
    ```

3. Export your [AWS Access Key/ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html). If you already have them under your `~/.aws/credentials` then you don't need to do this step.

    ```bash
    export AWS_ACCESS_KEY_ID="<your_accesskey_id>"
    export AWS_SECRET_ACCESS_KEY="<your_secretkey>"
    ```

4. Download this repo into your environment:

    ```bash
    git clone https://github.com/tigera-solutions/fortinet-enablement
    ```

5. Copy the supplied Calico Enterprise license (`license.yaml`) and pull secret (provided JSON file should be saved as `dockerjsonconfig.json`) into the new directory's `configs` subdirectory.

    ```text
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

[:arrow_right: Module 2](../modules/setting-up-aws.md)

[:leftwards_arrow_with_hook: Back to Main](/README.md)
