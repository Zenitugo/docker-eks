
output "eks-sg" {
    value    = aws_security_group.allow_tls.id
}