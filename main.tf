terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "fortinet-calico-vpc" {
  cidr_block = var.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags = {
    Name = "fortinet-calico-vpc"
  }
}

# Create a public subnet to launch our instances into
resource "aws_subnet" "fortinet-calico-pvt-subnet" {
  vpc_id                  = aws_vpc.fortinet-calico-vpc.id
  cidr_block              = var.privatecidraz1
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "fortinet-calico-pvt-subnet",
    "kubernetes.io/cluster/kubernetes" = "owned",
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create a private subnet to launch our instances into
resource "aws_subnet" "fortinet-calico-pub-subnet" {
  vpc_id                  = aws_vpc.fortinet-calico-vpc.id
  cidr_block              = var.publiccidraz1
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "fortinet-calico-pub-subnet",
    "kubernetes.io/cluster/kubernetes" = "owned",
    "kubernetes.io/role/elb" = "1"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "fortinet-calico-igw" {
  vpc_id = aws_vpc.fortinet-calico-vpc.id
  tags = {
    Name = "fortinet-calico-igw"
  } 
}

// Route Table
resource "aws_route_table" "fortinet-calico-public-rt" {
  vpc_id = aws_vpc.fortinet-calico-vpc.id
  tags = {
    Name = "fortinet-calico-public-rt"
  }
}

resource "aws_route_table" "fortinet-calico-private-rt" {
  vpc_id = aws_vpc.fortinet-calico-vpc.id
  tags = {
    Name = "fortinet-calico-private-rt"
  }
}

// Routes
resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.fortinet-calico-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fortinet-calico-igw.id
}

resource "aws_route" "internalroute" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fortinet-calico-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1.id

}

## Route Table Association
resource "aws_route_table_association" "public1associate" {
  subnet_id      = aws_subnet.fortinet-calico-pub-subnet.id
  route_table_id = aws_route_table.fortinet-calico-public-rt.id
}

resource "aws_route_table_association" "internalassociate" {
  subnet_id      = aws_subnet.fortinet-calico-pvt-subnet.id
  route_table_id = aws_route_table.fortinet-calico-private-rt.id
}

resource "aws_eip" "FGTPublicIP" {
  depends_on        = [aws_instance.fgtvm]
  vpc               = true
  network_interface = aws_network_interface.eth0.id
}

resource "aws_eip" "FMRPublicIP" {
  depends_on        = [aws_instance.fgtvm]
  vpc               = true
  network_interface = aws_network_interface.fmrvm_eth0.id
}

# Our default security group
resource "aws_security_group" "default" {
  name        = "calico-fortinet-sg"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.fortinet-calico-vpc.id

  # SSH, HTTPs, and kube access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["10.99.0.0/16"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## IAM Role and Policy for k8s Nodes

resource "aws_iam_role" "k8s-access-role" {
  name               = "k8s-access-role"
  assume_role_policy = file("iamrole.json")
}

resource "aws_iam_policy" "k8s-access-policy" {
  name        = "k8s-access-policy"
  description = "k8s aws controller policy"
  policy      = file("iampolicy.json")
}

resource "aws_iam_policy_attachment" "k8s-policy-attach" {
  name       = "policy-attach"
  roles      = [aws_iam_role.k8s-access-role.name]
  policy_arn = aws_iam_policy.k8s-access-policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name  = "instance_profile"
  role = aws_iam_role.k8s-access-role.name
}


resource "aws_instance" "master" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
  }
  instance_type = "t3.xlarge"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  source_dest_check = false 
  ami = var.aws_amis[var.aws_region]
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.fortinet-calico-pub-subnet.id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  provisioner "file" {
    source      = "configs"
    destination = "/home/ubuntu/calico-fortinet"
  }

  provisioner "file" {
    source      = "demo"
    destination = "/home/ubuntu/calico-fortinet"
  }

  tags = {
    Name = "master",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

resource "aws_instance" "worker-1" {

  instance_type = "t3.xlarge"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  source_dest_check = false 
  ami = var.aws_amis[var.aws_region]
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.fortinet-calico-pvt-subnet.id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }
  tags = {
    Name = "worker-1",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

resource "aws_instance" "worker-2" {
  instance_type = "t3.xlarge"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  source_dest_check = false 
  ami = var.aws_amis[var.aws_region]
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.fortinet-calico-pvt-subnet.id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }
  tags = {
    Name = "worker-2",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

// FMR instance
resource "aws_network_interface" "fmrvm_eth0" {
  description = "fmrvm-port1"
  subnet_id   = aws_subnet.fortinet-calico-pub-subnet.id
}
resource "aws_network_interface" "fmrvm_eth1" {
  description       = "fmrvm-port2"
  subnet_id         = aws_subnet.fortinet-calico-pvt-subnet.id
  source_dest_check = false
}
resource "aws_network_interface_sg_attachment" "fmrpublicattachment" {
  depends_on           = [aws_network_interface.fmrvm_eth0]
  security_group_id    = aws_security_group.default.id
  network_interface_id = aws_network_interface.fmrvm_eth0.id
}
resource "aws_network_interface_sg_attachment" "fmrinternalattachment" {
  depends_on           = [aws_network_interface.fmrvm_eth1]
  security_group_id    = aws_security_group.default.id
  network_interface_id = aws_network_interface.fmrvm_eth1.id
}

resource "aws_instance" "fmrvm" {
  ami               = lookup(var.fmrvmami, var.aws_region)
  instance_type     = var.fmr_size
  availability_zone = var.az1
  key_name          = var.key_name

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "80"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.fmrvm_eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fmrvm_eth1.id
    device_index         = 1
  }

  tags = {
    Name = "FortiManagerVM"
  }
}


// FortiGate instance
resource "aws_network_interface" "eth0" {
  description = "fgtvm-port1"
  subnet_id   = aws_subnet.fortinet-calico-pub-subnet.id
}
resource "aws_network_interface" "eth1" {
  description       = "fgtvm-port2"
  subnet_id         = aws_subnet.fortinet-calico-pvt-subnet.id
  source_dest_check = false
}
resource "aws_network_interface_sg_attachment" "publicattachment" {
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.default.id
  network_interface_id = aws_network_interface.eth0.id
}
resource "aws_network_interface_sg_attachment" "internalattachment" {
  depends_on           = [aws_network_interface.eth1]
  security_group_id    = aws_security_group.default.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_instance" "fgtvm" {
  ami               = lookup(var.fgtvmami, var.aws_region)
  instance_type     = var.fgt_size
  availability_zone = var.az1
  key_name          = var.key_name
  user_data         = data.template_file.FortiGate.rendered

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "80"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  tags = {
    Name = "FortiGateVM"
  }
}

data "template_file" "FortiGate" {
  template = file(var.bootstrap-fgtvm)
  vars = {
    adminsport = var.adminsport
  }
}
