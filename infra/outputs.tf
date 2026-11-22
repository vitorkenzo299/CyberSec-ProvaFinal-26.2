output "project_name" { value = local.name }
locals {
  bootstrap_encoded_sizes = { for role, node in aws_instance.node : role => length(node.user_data_base64) }
}
output "application_url" { value = "https://${var.domain_name == null ? aws_cloudfront_distribution.lab.domain_name : var.domain_name}" }
output "vpn_public_ip" { value = aws_instance.node["vpn"].public_ip }
output "vpn_profile_parameter" {
  value       = "${local.secret_dir}/vpn/client"
  description = "Nome do parametro privado; o perfil nao e exportado pelo Terraform."
}
output "private_addresses" { value = { web = local.web_ip, wazuh = local.wazuh_ip } }
output "wazuh_url_over_vpn" { value = "https://${local.wazuh_ip}" }
output "instance_ids" { value = { for key, node in aws_instance.node : key => node.id } }
output "vpc_id" { value = aws_vpc.lab.id }
output "database_identifier" { value = aws_db_instance.lab.identifier }
output "web_acl_id" { value = aws_wafv2_web_acl.lab.id }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.lab.id }
output "log_groups" { value = { system = aws_cloudwatch_log_group.system.name, waf = aws_cloudwatch_log_group.waf.name, flow = aws_cloudwatch_log_group.flow.name } }
output "cloudwatch_dashboard" { value = local.name }
output "audit_bucket" { value = aws_s3_bucket.audit.id }
