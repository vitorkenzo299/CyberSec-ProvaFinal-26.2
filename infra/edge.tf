data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "viewer" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${local.name}"
  retention_in_days = 7
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
  # Marcador benigno: prova o caminho CloudFront -> WAF sem explorar a aplicação.
  rule {
    name     = "ControlledEvidenceProbe"
    priority = 0
    action {
      block {}
    }
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
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ControlledEvidenceProbe"
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
        aggregate_key_type    = "IP"
        evaluation_window_sec = 300
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
  comment             = "Laboratorio final independente ${local.name}"
  price_class         = "PriceClass_100"
  aliases             = var.domain_name == null ? [] : [var.domain_name]
  web_acl_id          = aws_wafv2_web_acl.lab.arn
  wait_for_deployment = true
  origin {
    domain_name = aws_instance.node["web"].private_dns
    origin_id   = "private-web"
    vpc_origin_config { vpc_origin_id = aws_cloudfront_vpc_origin.web.id }
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
