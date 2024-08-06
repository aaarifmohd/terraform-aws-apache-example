output "public_ips" {
    value = aws_instance.my-server.public_ip
}