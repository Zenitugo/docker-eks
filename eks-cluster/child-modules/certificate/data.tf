# Query aws infrastructure to get the domain name registered in route53
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  private_zone = false
}
