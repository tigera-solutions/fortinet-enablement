# Module 2: Creating Your AWS Environment with Terraform

Goal: this module sets up your AWS environment using Terraform. 

### Steps

1. Export your AWS Access Key/ID

    ```
    $ export AWS_ACCESS_KEY_ID="anaccesskey"
    $ export AWS_SECRET_ACCESS_KEY="asecretkey"
    ```

2. Assuming your SSH public key is named `mykey.pub` and your private SSH key is named `mykey.pem` and the Key Pair name in AWS is named `mykey`. You need to first enable SSH forwarding locally as follows:

    ```
    $  eval `ssh-agent -s`
    $  ssh-add ~/.ssh/mykey.pem 
    ```

3. Now you need to make a copy of `terrafrom.tfvars.template` and name it `terraform.tfvars` to specify the AWS key name, path, and your AWS region. Make sure you rename the terraform file `terrafrom.tfvars`. 

    ```
    🐯 → cat terraform.tfvars 
    key_name        = "mykey"
    ```

4. **If you're using `us-west-2` region, skip this step.** Ensure that the correct AMI for your region is present in `variables.tf` for `aws_amis` , `fgtvmami` and `fmrvmami` variables. We will use **Ubuntu 20.04 LTS** image. You can use [this](http://cloud-images.ubuntu.com/locator/ec2/) site to find the right AMI matching. Please note that if you intend to use a different region other than `us-west-2`, you need to add the AMIs accordingly. 

    ```
        # Ubuntu 20.04 LTS (x64)
        variable "aws_amis" {
        default = {
            us-west-2 = "ami-01a5f3ee4a9903e77"
        }
        }
    ```

5. Initialize, Plan, and Apply Terraform.  After some time, you should see all the necessary outputs to log into your instances.


```
🐯 → terraform init

Initializing the backend...

Initializing provider plugins...
- Using previously-installed hashicorp/aws v3.11.0
- Using previously-installed hashicorp/template v2.2.0

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/template: version = "~> 2.2.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
```
    $ terraform plan
    ....
```
```
     $  terraform apply
data.template_file.FortiGate: Refreshing state... [id=d323b53709bb0d747ab8c01fba8e5b121202f4c3e14ecbd416c068480edeccb2]
aws_key_pair.auth: Refreshing state... [id=dockey]
aws_vpc.fortinet-calico-vpc: Refreshing state... [id=vpc-0c5f6158be95edea0]
aws_route_table.fortinet-calico-public-rt: Refreshing state... [id=rtb-0a17fde69ec53b3f6]
aws_route_table.fortinet-calico-private-rt: Refreshing state... [id=rtb-0d081e3b0a4e87c0c]
aws_internet_gateway.fortinet-calico-igw: Refreshing state... [id=igw-044ee09e56bd9afe3]
aws_subnet.fortinet-calico-pub-subnet: Refreshing state... [id=subnet-0b26da7791c17be5c]
aws_subnet.fortinet-calico-pvt-subnet: Refreshing state... [id=subnet-0e07a84647fb694c4]
aws_security_group.default: Refreshing state... [id=sg-0a4478402a8124941]
aws_route.externalroute: Refreshing state... [id=r-rtb-0a17fde69ec53b3f61080289494]
aws_route_table_association.internalassociate: Refreshing state... [id=rtbassoc-03e877168447a3290]
aws_network_interface.fmrvm_eth1: Refreshing state... [id=eni-02568bef2c5049c32]
aws_network_interface.eth1: Refreshing state... [id=eni-0454d6212de3c7972]
aws_network_interface.fmrvm_eth0: Refreshing state... [id=eni-051c79abbdeefe4d4]
aws_route_table_association.public1associate: Refreshing state... [id=rtbassoc-0e369b640bca4b4a4]
    ....

    Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
  ...


    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

FGTPublicIP = 44.237.X.X
FortiGatePassword = i-034917bd90XXXX
FortiManagerPassword = i-086dec29XXXX
FortiManagerPublicIP = 18.X.X.X
FortiManagerUsername = admin
FortigateUsername = admin
jumpbox-ip = 18.X.X.X
master-ip = 10.99.2.X
worker-1-ip = 10.99.2.X
worker-2-ip = 10.99.2.X
```

Note: If you never accepter Terms of Use for using Fortigate & FortiManager Pay-As-You-Go, you will be required to do so and the operation will fail and point you to the URL to go through that process.


6. You should now be able to SSH into the `jumpbox` VM.



