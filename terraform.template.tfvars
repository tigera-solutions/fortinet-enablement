// AWS Key Name
variable "key_name" {
  default = "NAME"
  public_key_path = "~/PATH/"
}

variable "aws_region" {
  default = "us-west-2"
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

// AMIs are for FGTVM-AWS(PAYG) - 6.4.2
variable "fgtvmami" {
  type = map
  default = {
    us-west-2      = "ami-036c4658b4595cc72"
  }
}

variable "size" {
  default = "c5n.xlarge"
}


variable "adminsport" {
  default = "8443"
}

variable "bootstrap-fgtvm" {
  // Change to your own path
  type    = string
  default = "fgtvm.conf"
}