# Frontend EC2 instance
resource "aws_instance" "frontend_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  tags = {
    Name = "${var.application_name}-${var.environment}-frontend-vm"
  }
}

# Backend EC2 instance
resource "aws_instance" "backend_vm" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  tags = {
    Name = "${var.application_name}-${var.environment}-backend-vm"
  }
}
