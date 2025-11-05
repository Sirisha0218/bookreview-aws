variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair"
  type        = string
}

variable "web_ami_id" {
  description = "AMI ID for the web (frontend) instance"
  type        = string
}

variable "db_ami_id" {
  description = "AMI ID for the db (backend) instance"
  type        = string
}
