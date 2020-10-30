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
    us-west-2 = "ami-01a5f3ee4a9903e77"
  }
}

// AMIs are for FGTVM-AWS(PAYG) - 6.4.2
variable "fgtvmami" {
  type = map
  default = {
    us-west-2= "ami-03ee081dace39500a"
  }
}

// AMIs are for FMRVM-AWS(PAYG) 
variable "fmrvmami" {
  type = map
  default = {
    us-west-2= "ami-00794bab7e9fd778a"
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