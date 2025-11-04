output "frontend_public_ip" {
  value = aws_instance.frontend_vm.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend_vm.public_ip
}
