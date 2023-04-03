variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

// Availability zones for the region
variable "az1" {
  default = "us-west-2a"
}

variable "az2" {
  default = "us-west-2b"
}

variable "vpccidr" {
  default = "10.99.0.0/16"
}

variable "publiccidraz1" {
  default = "10.99.1.0/24"
}

variable "privatecidraz1" {
  default = "10.99.2.0/24"
}

# Ubuntu 20.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-west-2 = "ami-0ceee60bcb94f60cd"
    # Ubuntu 22.04 LTS
    #us-west-2 = "ami-0fcf52bcf5db7b003"
  }
}

// AMIs are for FGTVM-AWS(PAYG) - 6.2.5
variable "fgtvmami" {
  type = map
  default = {
    us-west-2= "ami-05cfe4f5761707079"
    # FortiGate-VM64-AWSONDEMAND 7.2.4
    #us-west-2= "ami-023d43c8c28258f24"
  }
}

// AMIs are for FMRVM-AWS(PAYG) - 6.4.4
variable "fmrvmami" {
  type = map
  default = {
    us-west-2= "ami-08acdd33410d45c74"
    # FortiManager VM64-AWSONDEMAND 7.2.2 w/ free trial
    #us-west-2= "ami-0bda558c8e6199143"
  }
}

variable "fgt_size" {
  default = "c5.large"
}

variable "fmr_size" {
  default = "m5.large"
}


variable "adminsport" {
  default = "443"
}

variable "bootstrap-fgtvm" {
  // Change to your own path
  type    = string
  default = "fgtvm.conf"
}

// resource prefix variable
variable "resource_prefix" {
  default = "califn-"
}