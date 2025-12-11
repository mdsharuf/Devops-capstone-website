variable "region" {
  type    = string
  default = "ap-south-1" # change if you prefer
}

variable "ami_id" {
  type    = string
  description = "AMI id to use for EC2 instances (Ubuntu 22.04 / 20.04 recommended)"
  default = "" # set this when running or via tfvars
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "key_name" {
  type        = string
  description = "Name of existing AWS key pair (must exist in region)"
}

variable "private_key_path" {
  type        = string
  description = "Path to your private key file on local machine for Terraform remote-exec (optional)"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu" # most Ubuntu AMIs use ubuntu user
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"] # change to your IP/CIDR for security
}
