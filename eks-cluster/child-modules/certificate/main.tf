# Create an aws public ssl certificate
resource "aws_acm_certificate" "aws_ssl_cert" {
  domain_name                     = var.domain_name
  subject_alternative_names       = [var.alternative_name]
  validation_method               = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


# Validate domain name by creating a record set
resource "aws_route53_record" "domain" {
  for_each = {
    for dvo in aws_acm_certificate.aws_ssl_cert.domain_validation_options : dvo.domain_name => {
      name                           = dvo.resource_record_name
      record                         = dvo.resource_record_value
      type                           = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name                               = each.value.name
  records                            = [each.value.record]
  ttl                                = 60
  type                               = each.value.type
  zone_id                            = data.aws_route53_zone.hosted_zone.zone_id
}


# Validate your ssl certificate
resource "aws_acm_certificate_validation" "ssl_cert_validate" {
  certificate_arn                    = aws_acm_certificate.aws_ssl_cert.arn
  validation_record_fqdns            = [for record in aws_route53_record.domain : record.fqdn]
}