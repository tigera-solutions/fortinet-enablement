# Module 2: Creating Your AWS Environment with Terraform

Goal: this module sets up your AWS environment using Terraform. 

### Steps

1. Export your AWS Access Key/ID

    ```
    $ export AWS_ACCESS_KEY_ID="anaccesskey"
    $ export AWS_SECRET_ACCESS_KEY="asecretkey"
    ```

2. Configure the corresponding SSH key name and path. This step assumes you have already created an SSH key pair in your AWS account/region. You first need to run an ssh agent and configure it to use your private key. Then you can use the `terrafrom.template.tfvars` to specify the AWS key name,path, and your AWS region to your local public key. Make sure you rename the terraform file `terrafrom.tfvars`. 

    ```
    $  eval `ssh-agent -s`
    $  ssh-add ~/.ssh/mykey.pem 
    ```

    🐯 → cat terraform.tfvars 
    aws_region     = "us-west-2"
    key_name        = "mykey"
    public_key_path = "~/.ssh/mykey.pub"
    ```

3. Ensure that the correct AMI for your region is present in `terrafrom.tfvars` for `aws_amis` , `fgtvmami` and `fmrvmami` variables. We will use **Ubuntu 20.04 LTS** image. You can use [this](http://cloud-images.ubuntu.com/locator/ec2/) site to find the right AMI matching. Please note that if you intend to use a different region other than `us-west-2`, you need to add the AMIs accordingly.

    ```
        # Ubuntu 20.04 LTS (x64)
        variable "aws_amis" {
        default = {
            us-west-2 = "ami-01a5f3ee4a9903e77"
        }
        }
    ```

4. Initialize, Plan, and Apply Terraform.  After some time, you should see all the necessary outputs to log into your instances.

    ```
    $  terraform init
    $  terraform plan
    $  terraform apply
    ....


Apply complete! Resources: 0 added, 9 changed, 0 destroyed.

Outputs:

FGTPublicIP = 52.26.x.x
FortiGate-Password = i-xxxxx
FortiGatePassword = i-xxxxxxx
FortiManagerUsername = admin
FortigateUsername = admin
master-ip = 10.99.1.x
worker-1-ip = 10.99.1.x
worker-2-ip = 10.99.1.x
jumpbox-ip = 52.26.x.x
```
