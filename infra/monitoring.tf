data "aws_sns_topic" "existing_alerts" {
  name = "ABCPlace-R4-Alertas"
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "/${local.name}/system"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "flow" {
  name              = "/${local.name}/vpc-flow"
  retention_in_days = 7
}
resource "aws_iam_role" "flow" {
  name = "${local.name}-flow-logs"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect    = "Allow", Principal = { Service = "vpc-flow-logs.amazonaws.com" }, Action = "sts:AssumeRole",
    Condition = { StringEquals = { "aws:SourceAccount" = var.expected_account_id } }
  }] })
}
resource "aws_iam_role_policy" "flow" {
  role = aws_iam_role.flow.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = [aws_cloudwatch_log_group.flow.arn, "${aws_cloudwatch_log_group.flow.arn}:*"] },
    { Effect = "Allow", Action = ["logs:DescribeLogGroups"], Resource = "*" }
  ] })
}
resource "aws_flow_log" "lab" {
  iam_role_arn         = aws_iam_role.flow.arn
  log_destination      = aws_cloudwatch_log_group.flow.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.lab.id
  depends_on           = [aws_iam_role_policy.flow]
}
resource "aws_cloudwatch_metric_alarm" "cpu" {
  actions_enabled     = var.enable_alarm_notifications
  for_each            = local.nodes
  alarm_name          = "${local.name}-${each.key}-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = each.key == "web" ? 1 : 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = each.key == "web" ? 70 : 80
  treat_missing_data  = "missing"
  dimensions          = { InstanceId = aws_instance.node[each.key].id }
  alarm_description   = each.key == "web" ? "R4: CPU Web acima de 70% em um periodo de 5 minutos; SNS existente." : "CPU acima de 80% por 10 minutos; continuidade ABC Place R4 via SNS existente."
  alarm_actions       = [data.aws_sns_topic.existing_alerts.arn]
  ok_actions          = [data.aws_sns_topic.existing_alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "status" {
  actions_enabled     = var.enable_alarm_notifications
  for_each            = local.nodes
  alarm_name          = "${local.name}-${each.key}-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "missing"
  dimensions          = { InstanceId = aws_instance.node[each.key].id }
  alarm_actions       = [data.aws_sns_topic.existing_alerts.arn]
  ok_actions          = [data.aws_sns_topic.existing_alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "network_web" {
  actions_enabled     = var.enable_alarm_notifications
  alarm_name          = "${local.name}-web-network"
  alarm_description   = "R4: 1 MB decimal por minuto = NetworkIn + NetworkOut > 1000000 bytes em 60s."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1000000
  treat_missing_data  = "missing"
  alarm_actions       = [data.aws_sns_topic.existing_alerts.arn]
  ok_actions          = [data.aws_sns_topic.existing_alerts.arn]
  metric_query {
    id          = "total"
    expression  = "incoming+outgoing"
    label       = "Bytes por minuto"
    return_data = true
  }
  dynamic "metric_query" {
    for_each = { incoming = "NetworkIn", outgoing = "NetworkOut" }
    content {
      id          = metric_query.key
      return_data = false
      metric {
        metric_name = metric_query.value
        namespace   = "AWS/EC2"
        period      = 60
        stat        = "Sum"
        dimensions  = { InstanceId = aws_instance.node["web"].id }
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "disk_web" {
  actions_enabled     = var.enable_alarm_notifications
  alarm_name          = "${local.name}-web-disk"
  alarm_description   = "R4: ocupacao do sistema de arquivos raiz acima de 85%; CWAgent, nao DiskWriteBytes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  treat_missing_data  = "missing"
  dimensions          = { InstanceId = aws_instance.node["web"].id, path = "/", fstype = "ext4" }
  alarm_actions       = [data.aws_sns_topic.existing_alerts.arn]
  ok_actions          = [data.aws_sns_topic.existing_alerts.arn]
}
resource "aws_cloudwatch_dashboard" "lab" {
  dashboard_name = local.name
  dashboard_body = jsonencode({ widgets = [
    { type = "alarm", x = 0, y = 0, width = 24, height = 3, properties = {
      title  = "ABC Place final e SNS do Roteiro 4",
      alarms = concat([for role in ["web", "vpn", "wazuh"] : aws_cloudwatch_metric_alarm.cpu[role].arn], [for role in ["web", "vpn", "wazuh"] : aws_cloudwatch_metric_alarm.status[role].arn], [aws_cloudwatch_metric_alarm.disk_web.arn, aws_cloudwatch_metric_alarm.network_web.arn])
    } },
    { type = "metric", x = 0, y = 3, width = 12, height = 6, properties = {
      title   = "CPU das instancias", region = "us-east-1", view = "timeSeries", period = 300,
      metrics = [for role in ["web", "vpn", "wazuh"] : ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.node[role].id]]
    } },
    { type = "metric", x = 12, y = 3, width = 12, height = 6, properties = {
      title   = "Banco de dados", region = "us-east-1", view = "timeSeries", period = 300,
      metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.lab.identifier]]
    } },
    { type = "metric", x = 0, y = 9, width = 12, height = 6, properties = {
      title = "R4 trafego Web por minuto", region = "us-east-1", view = "timeSeries", period = 60,
      metrics = [
        [{ expression = "incoming+outgoing", label = "Bytes por minuto", id = "total" }],
        ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.node["web"].id, { id = "incoming", visible = false, stat = "Sum" }],
        ["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.node["web"].id, { id = "outgoing", visible = false, stat = "Sum" }]
      ], annotations = { horizontal = [{ value = 1000000, label = "Limite 1 MB decimal/min" }] }
    } },
    { type = "metric", x = 12, y = 9, width = 12, height = 6, properties = {
      title   = "R4 ocupacao real da raiz Web", region = "us-east-1", view = "timeSeries", period = 60,
      metrics = [["CWAgent", "disk_used_percent", "InstanceId", aws_instance.node["web"].id, "path", "/", "fstype", "ext4"]],
      yAxis   = { left = { min = 0, max = 100 } }, annotations = { horizontal = [{ value = 85, label = "Limite 85%" }] }
    } }
  ] })
}

resource "aws_s3_bucket" "audit" {
  bucket        = "${local.name}-audit-${var.expected_account_id}"
  force_destroy = false
}
resource "aws_s3_bucket_public_access_block" "audit" {
  bucket                  = aws_s3_bucket.audit.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Sid       = "CloudTrailAcl", Effect = "Allow", Principal = { Service = "cloudtrail.amazonaws.com" },
      Action    = "s3:GetBucketAcl", Resource = aws_s3_bucket.audit.arn,
      Condition = { StringEquals = { "aws:SourceArn" = "arn:aws:cloudtrail:us-east-1:${var.expected_account_id}:trail/${local.name}" } }
    },
    { Sid       = "CloudTrailWrite", Effect = "Allow", Principal = { Service = "cloudtrail.amazonaws.com" },
      Action    = "s3:PutObject", Resource = "${aws_s3_bucket.audit.arn}/AWSLogs/${var.expected_account_id}/*",
      Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control", "aws:SourceArn" = "arn:aws:cloudtrail:us-east-1:${var.expected_account_id}:trail/${local.name}" } }
    },
    { Sid      = "RequireTLS", Effect = "Deny", Principal = "*", Action = "s3:*",
      Resource = [aws_s3_bucket.audit.arn, "${aws_s3_bucket.audit.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }
  ] })
}
resource "aws_cloudtrail" "lab" {
  name                          = local.name
  s3_bucket_name                = aws_s3_bucket.audit.id
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true
  depends_on                    = [aws_s3_bucket_policy.audit, aws_s3_bucket_public_access_block.audit]
}
