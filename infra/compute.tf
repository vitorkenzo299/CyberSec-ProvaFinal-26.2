data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
locals {
  nodes = {
    vpn   = { ip = local.vpn_ip, public = true, type = "t3.micro", disk = 8 }
    web   = { ip = local.web_ip, public = false, type = "t3.micro", disk = 10 }
    wazuh = { ip = local.wazuh_ip, public = false, type = "t3.xlarge", disk = 50 }
  }
}
resource "aws_iam_role" "node" {
  for_each = local.nodes
  name     = "${local.name}-${each.key}"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole"
  }] })
}
resource "aws_iam_role_policy" "ssm" {
  for_each = local.nodes
  role     = aws_iam_role.node[each.key].id
  # Operação do agente sem leitura geral de parâmetros de outros projetos.
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Resource = "*", Action = [
      "ssm:DescribeAssociation", "ssm:GetDeployablePatchSnapshotForInstance", "ssm:GetDocument", "ssm:DescribeDocument", "ssm:GetManifest",
      "ssm:ListAssociations", "ssm:ListInstanceAssociations", "ssm:PutInventory", "ssm:PutComplianceItems", "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus", "ssm:UpdateInstanceAssociationStatus", "ssm:UpdateInstanceInformation"
    ] },
    { Effect = "Allow", Resource = "*", Action = ["ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel"] }
  ] })
}
resource "aws_iam_role_policy" "logs" {
  for_each = local.nodes
  role     = aws_iam_role.node[each.key].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = [aws_cloudwatch_log_group.system.arn, "${aws_cloudwatch_log_group.system.arn}:*"] },
    { Effect = "Allow", Action = ["logs:DescribeLogGroups"], Resource = "*" }
  ] })
}
resource "aws_iam_role_policy" "web_secret" {
  role = aws_iam_role.node["web"].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = aws_secretsmanager_secret.app.arn },
    { Effect    = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = aws_db_instance.lab.master_user_secret[0].secret_arn,
      Condition = { DateLessThan = { "aws:CurrentTime" = timeadd(time_static.bootstrap.rfc3339, "2h") } }
    }
  ] })
}
resource "aws_iam_role_policy" "private_profile" {
  role = aws_iam_role.node["vpn"].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect   = "Allow", Action = ["ssm:PutParameter"],
    Resource = "arn:aws:ssm:us-east-1:${var.expected_account_id}:parameter${local.secret_dir}/vpn/client"
  }] })
}
resource "aws_iam_instance_profile" "node" {
  for_each = local.nodes
  name     = "${local.name}-${each.key}"
  role     = aws_iam_role.node[each.key].name
}
resource "aws_instance" "node" {
  for_each                    = local.nodes
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.type
  subnet_id                   = each.value.public ? aws_subnet.public[0].id : aws_subnet.private[0].id
  private_ip                  = each.value.ip
  associate_public_ip_address = each.value.public
  vpc_security_group_ids      = [aws_security_group.node[each.key].id]
  iam_instance_profile        = aws_iam_instance_profile.node[each.key].name
  source_dest_check           = each.key != "vpn"
  user_data_replace_on_change = true
  user_data_base64 = base64gzip(templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    operator   = var.operator_name
    public_key = var.ssh_public_key
    common_b64 = base64encode(file("${path.module}/scripts/common.sh"))
    role_b64   = base64encode(file("${path.module}/scripts/${each.key}.sh"))
    config_json = jsonencode({
      project                = local.name, role = each.key, region = "us-east-1", operator = var.operator_name,
      wazuh_ip               = local.wazuh_ip, web_ip = local.web_ip, vpn_ip = local.vpn_ip,
      vpc_cidr               = local.vpc_cidr, vpn_cidr = local.vpn_cidr,
      app_secret             = aws_secretsmanager_secret.app.arn,
      master_secret          = aws_db_instance.lab.master_user_secret[0].secret_arn,
      database_host          = aws_db_instance.lab.address,
      vpn_parameter          = "${local.secret_dir}/vpn/client",
      system_log_group       = aws_cloudwatch_log_group.system.name,
      wazuh_installer_sha256 = var.wazuh_installer_sha256,
      application            = each.key == "web" ? { for name in ["server.py", "index.html", "style.css", "app.js"] : name => filebase64("${path.module}/../app/${name}") } : {}
    })
  }))
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = each.value.disk
    delete_on_termination = true
  }
  credit_specification { cpu_credits = "standard" }
  # cloud-init é um bootstrap de primeiro uso. Ajustes posteriores são aplicados
  # explicitamente pelos procedimentos de operação, sem recriar hosts em atividade.
  lifecycle {
    ignore_changes = [user_data_base64]
  }
  tags       = { Name = "${local.name}-${each.key}", Role = each.key }
  depends_on = [terraform_data.identity_guard, aws_route_table_association.private, aws_route_table_association.public, aws_iam_role_policy.web_secret, aws_iam_role_policy.private_profile, aws_iam_role_policy.logs, aws_iam_role_policy.ssm, aws_secretsmanager_secret_version.app, aws_vpc_security_group_egress_rule.https, aws_vpc_security_group_egress_rule.apt, aws_vpc_security_group_egress_rule.wazuh, aws_vpc_security_group_egress_rule.database, aws_vpc_security_group_ingress_rule.database, aws_vpc_security_group_ingress_rule.wazuh, aws_vpc_security_group_ingress_rule.ssh, aws_vpc_security_group_ingress_rule.vpn, aws_vpc_security_group_ingress_rule.web]
}
