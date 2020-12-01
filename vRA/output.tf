// AWS outputs

output "address" {
  value = aws_instance.velo-instance.id
}

output "private-key" {
    value = tls_private_key.velo-key.private_key_pem
}