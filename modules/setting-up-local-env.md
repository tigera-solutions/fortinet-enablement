# Module 1: Setting up your local environment.

**Goal:** We need to make sure your local environment is set up correctly.

### Steps 

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