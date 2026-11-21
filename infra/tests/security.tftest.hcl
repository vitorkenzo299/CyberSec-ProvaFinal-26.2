mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = { account_id = "111122223333", arn = "arn:aws:iam::111122223333:user/vitor", user_id = "local-test" }
  }
  mock_data "aws_availability_zones" {
    defaults = { names = ["us-east-1a", "us-east-1b"] }
  }
  mock_data "aws_ami" {
    defaults = { id = "ami-0123456789abcdef0" }
  }
  mock_data "aws_ec2_managed_prefix_list" {
    defaults = { id = "pl-0123456789abcdef0" }
  }
  mock_resource "aws_db_instance" {
    defaults = {
      address            = "database.test.rds.amazonaws.com"
      master_user_secret = [{ secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:bootstrap-abcdef", secret_status = "active", kms_key_id = "11111111-1111-1111-1111-111111111111" }]
    }
  }
  mock_resource "aws_secretsmanager_secret" {
    defaults = { arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:app-abcdef" }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = { arn = "arn:aws:logs:us-east-1:111122223333:log-group:local-test" }
  }
  mock_resource "aws_instance" {
    defaults = { arn = "arn:aws:ec2:us-east-1:111122223333:instance/i-0123456789abcdef0", private_dns = "ip-10-62-10-10.ec2.internal" }
  }
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::111122223333:role/local-test" }
  }
  mock_resource "aws_wafv2_web_acl" {
    defaults = { arn = "arn:aws:wafv2:us-east-1:111122223333:global/webacl/local-test/11111111-1111-1111-1111-111111111111" }
  }
}
mock_provider "random" {
  mock_resource "random_id" {
    defaults = { hex = "abc123" }
  }
}
mock_provider "time" {
  mock_resource "time_static" {
    defaults = { rfc3339 = "2026-11-21T12:00:00Z" }
  }
}

variables {
  expected_account_id    = "111122223333"
  administrator_cidr     = "203.0.113.10/32"
  ssh_public_key         = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestOnlyPublicKeyForOfflinePlan"
  wazuh_installer_sha256 = "0000000000000000000000000000000000000000000000000000000000000000"
}

run "secure_network_and_storage" {
  # Todos os provedores externos são mocks; apply executa apenas a simulação.
  command = apply
  assert {
    condition     = !aws_instance.node["web"].associate_public_ip_address && !aws_instance.node["wazuh"].associate_public_ip_address
    error_message = "Aplicação e Wazuh não podem receber IP público."
  }
  assert {
    condition     = alltrue([for node in aws_instance.node : node.metadata_options[0].http_tokens == "required" && node.root_block_device[0].encrypted])
    error_message = "Exigir IMDSv2 e disco criptografado em todas as instâncias."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.vpn.cidr_ipv4 == "203.0.113.10/32" && aws_vpc_security_group_ingress_rule.vpn.from_port == 1194
    error_message = "VPN deve aceitar somente UDP 1194 da origem individual."
  }
  assert {
    condition     = alltrue([for rule in aws_vpc_security_group_ingress_rule.ssh : rule.referenced_security_group_id == aws_security_group.node["vpn"].id && rule.cidr_ipv4 == null])
    error_message = "SSH deve ser permitido apenas a partir do Security Group da VPN."
  }
  assert {
    condition     = !aws_db_instance.lab.publicly_accessible && aws_db_instance.lab.storage_encrypted && aws_db_instance.lab.backup_retention_period == 7 && aws_db_instance.lab.deletion_protection
    error_message = "RDS deve ser privado, criptografado, protegido e ter backup."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.database.referenced_security_group_id == aws_security_group.node["web"].id && aws_vpc_security_group_ingress_rule.database.from_port == 3306
    error_message = "Somente o servidor web pode alcançar MySQL."
  }
  assert {
    condition     = aws_cloudfront_distribution.lab.web_acl_id == aws_wafv2_web_acl.lab.arn && aws_cloudfront_distribution.lab.default_cache_behavior[0].viewer_protocol_policy == "redirect-to-https"
    error_message = "O ponto de entrada público deve passar pelo WAF e forçar HTTPS."
  }
  assert {
    condition     = alltrue([for size in values(local.bootstrap_encoded_sizes) : size < 21844])
    error_message = "O bootstrap comprimido deve respeitar o limite EC2 de 16 KiB."
  }
}
