# Output domain name
output "domain_name" {
    value = var.domain_name
}


# Output the certificate arn 
output "cert_arn" {
    value = aws_acm_certificate.aws_ssl_cert.arn
}