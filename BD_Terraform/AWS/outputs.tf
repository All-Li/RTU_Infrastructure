output "my_server_public_ip" {
  value = aws_instance.BD_alizone_Server[*].public_ip
}