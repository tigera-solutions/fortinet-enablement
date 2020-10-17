# Fortinet and Calico Solution Integration Enablement Workshop

// TODO
- Organize the modules and ensure their names match
- Create a demo application and associted policy 
- Add the architecture diagram
- Add public Slack channel info
- FortiSIEM integration (optional)


![intro](https://docs.projectcalico.org/images/intro/performance.png)

## Summary and Goals

As a platform and security engineers, you want your apps to securely communicate with the external world. But you also want to secure the network traffic from the Kubernetes clusters using your Fortinet security fabricc. Using the Fortinet/Calico Enterprise integration, security teams can retain firewall responsibility, secure traffic using Calico Enterprise network policy, which frees up time for ITOps.

The goal of this enabelemnt tutorial is to demonstrate the value of the Fortinet+Calico Enterprise integration. Currently there are three areas of integration between Fortinet and Calico Enterprise:

1. Calico Enterprise + Fortigate
2. Calico Enterprise + FortiManager
3. Calico Enterprise + FortiSIEM


## Join the Slack Channel!

// TODO add public Slack channel info
We have created a slack channel on the Calico User Group to discuss all things related to Calico + Fortinet. 

## Pre-Requisites/Requirements

- Calico Enterprise Trial or Production License along with a pull secret. 
- AWS credentials with the IAM role to create:
  * VPC
  * Subnets
  * EC2 Instances
  * Secuirty Groups
- SSH client to connect to AWS resources
- A public/private SSH key created and added in your AWS account and for the specifc region you wish to run this in.
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) v0.13+ installed locally.

## Architecture

// TODO add architecture diagram here

## Workshop Modules

- [Module X: Preparing Your Setup](./modules/00.md)
- [Module X: Creating Your AWS Environment with Terraform](./modules/01.md)
- [Module X: Configuring Fortigate to allow internet traffic](./modules/x02.md)
- [Module X: Accessing the K8s Nodes](./modules/x03.md)
- [Module X: Creating Your Kubernetes Cluster](./modules/02.md)
- [Module X: Installing and Configuring Calico Enterprise](./modules/03.md)
- [Module X: Integrating FortiManager with FortiGate](./modules/05.md)
- [Module X: Integrating Calico Enterprise with FortiManager and FortiGate](./modules/04.md)
- [Module X: Running a Sample Application](./modules/06.md)
- [Module X: Installing FortiSIEM]()

### Cleanup

// TODO terraform destroy


