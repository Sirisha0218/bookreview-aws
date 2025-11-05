variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (e.g., Ubuntu 22.04 in your region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID where instances will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach to instances"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}
