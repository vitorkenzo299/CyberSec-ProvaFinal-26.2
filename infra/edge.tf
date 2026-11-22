data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "viewer" {
  name = var.domain_name == null ? "Managed-AllViewerExceptHostHeader" : "Managed-AllViewer"
}

resource "aws_cloudfront_function" "canonical_host" {
  count   = var.domain_name == null ? 0 : 1
  name    = "${local.name}-canonical-host"
  runtime = "cloudfront-js-2.0"
  comment = "Preserva URLs CloudFront antigas por redirecionamento para a loja final"
  publish = true
  code    = <<-JS
    function handler(event) {
      var request = event.request;
      if (request.headers.host.value === ${jsonencode(var.domain_name)}) return request;
      var parts = [];
      for (var key in request.querystring) {
        var entry = request.querystring[key];
        var values = entry.multiValue || [entry];
        for (var i = 0; i < values.length; i++) parts.push(key + '=' + values[i].value);
      }
      var location = 'https://' + ${jsonencode(var.domain_name)} + request.uri + (parts.length ? '?' + parts.join('&') : '');
      return {statusCode: 301, statusDescription: 'Moved Permanently', headers: {location: {value: location}}};
    }
  JS
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${local.name}"
  retention_in_days = 7
}
locals {
  cloudflare_ranges = jsondecode(file("${path.module}/cloudflare-ips.json"))
}
resource "aws_wafv2_ip_set" "cloudflare_v4" {
  name               = "${local.name}-cloudflare-v4"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.cloudflare_ranges.ipv4
}
resource "aws_wafv2_ip_set" "cloudflare_v6" {
  name               = "${local.name}-cloudflare-v6"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = local.cloudflare_ranges.ipv6
}
resource "aws_wafv2_web_acl" "lab" {
  name  = local.name
  scope = "CLOUDFRONT"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.name
    sampled_requests_enabled   = true
  }
  # A mesma regra preserva a prova benigna e exige Cloudflare no domínio final.
  rule {
    name     = "TrustedCloudflareIngress"
    priority = 0
    action {
      block {}
    }
    statement {
      or_statement {
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "blocked"
            field_to_match {
              single_header { name = "x-cyberfinal-test" }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          and_statement {
            statement {
              byte_match_statement {
                positional_constraint = "EXACTLY"
                search_string         = var.domain_name == null ? "final.abcplace.blog.br" : var.domain_name
                field_to_match {
                  single_header { name = "host" }
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
            statement {
              not_statement {
                statement {
                  ip_set_reference_statement { arn = aws_wafv2_ip_set.cloudflare_v4.arn }
                }
              }
            }
            statement {
              not_statement {
                statement {
                  ip_set_reference_statement { arn = aws_wafv2_ip_set.cloudflare_v6.arn }
                }
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "TrustedCloudflareIngress"
      sampled_requests_enabled   = true
    }
  }
  dynamic "rule" {
    for_each = { AWSManagedRulesCommonRuleSet = 10, AWSManagedRulesSQLiRuleSet = 20, AWSManagedRulesKnownBadInputsRuleSet = 30 }
    content {
      name     = rule.key
      priority = rule.value
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.key
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.key
        sampled_requests_enabled   = true
      }
    }
  }
  rule {
    name     = "RateLimit"
    priority = 40
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit                 = 100
        aggregate_key_type    = "FORWARDED_IP"
        evaluation_window_sec = 300
        forwarded_ip_config {
          header_name       = "CF-Connecting-IP"
          fallback_behavior = "MATCH"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }
}
resource "aws_wafv2_web_acl_logging_configuration" "lab" {
  resource_arn            = aws_wafv2_web_acl.lab.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  redacted_fields {
    single_header { name = "authorization" }
  }
  redacted_fields {
    single_header { name = "cookie" }
  }
  redacted_fields {
    query_string {}
  }
}

resource "aws_cloudfront_vpc_origin" "web" {
  vpc_origin_endpoint_config {
    name                   = local.name
    arn                    = aws_instance.node["web"].arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"
    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}
resource "aws_cloudfront_vpc_origin" "web_tls" {
  count = var.domain_name == null ? 0 : 1
  vpc_origin_endpoint_config {
    name                   = "${local.name}-tls"
    arn                    = aws_instance.node["web"].arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"
    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
  depends_on = [aws_vpc_security_group_ingress_rule.web_tls]
}
resource "aws_cloudfront_response_headers_policy" "lab" {
  name = local.name
  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = false
      override                   = true
    }
    content_type_options { override = true }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }
  }
}
resource "aws_cloudfront_distribution" "lab" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Evolucao ABC Place roteiros 1 a 4 ${local.name}"
  price_class         = "PriceClass_100"
  aliases             = var.domain_name == null ? [] : [var.domain_name]
  web_acl_id          = aws_wafv2_web_acl.lab.arn
  wait_for_deployment = true
  origin {
    domain_name = aws_instance.node["web"].private_dns
    origin_id   = "private-web"
    vpc_origin_config { vpc_origin_id = var.domain_name == null ? aws_cloudfront_vpc_origin.web.id : aws_cloudfront_vpc_origin.web_tls[0].id }
  }
  default_cache_behavior {
    target_origin_id           = "private-web"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.viewer.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.lab.id
    compress                   = true
    dynamic "function_association" {
      for_each = var.domain_name == null ? [] : [var.domain_name]
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.canonical_host[0].arn
      }
    }
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == null ? null : "sni-only"
    # O certificado padrão impõe TLSv1 no serviço, independentemente do valor solicitado.
    minimum_protocol_version = var.acm_certificate_arn == null ? "TLSv1" : "TLSv1.2_2021"
  }
  lifecycle {
    precondition {
      condition     = (var.domain_name == null) == (var.acm_certificate_arn == null)
      error_message = "Informe domínio e certificado ACM juntos, ou deixe ambos vazios para a demonstração inicial."
    }
  }
}
