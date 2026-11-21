data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" { state = "available" }
data "aws_ec2_managed_prefix_list" "cloudfront" { name = "com.amazonaws.global.cloudfront.origin-facing" }

resource "random_id" "suffix" { byte_length = 3 }
locals {
  name       = "${var.project_prefix}-${var.deployment_suffix}"
  vpc_cidr   = "10.62.0.0/16"
  vpn_cidr   = "10.99.0.0/24"
  vpn_ip     = "10.62.0.10"
  web_ip     = "10.62.10.10"
  wazuh_ip   = "10.62.10.20"
  secret_dir = "/${local.name}"
}

resource "terraform_data" "identity_guard" {
  lifecycle {
    precondition {
      condition     = !endswith(data.aws_caller_identity.current.arn, ":root") && !can(regex("(?i):user/(root|admin)$", data.aws_caller_identity.current.arn))
      error_message = "Use uma identidade nominal autorizada; root e o usuário genérico admin não são aceitos."
    }
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = local.name }
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-public-${count.index + 1}" }
}
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-private-${count.index + 1}" }
}
resource "aws_subnet" "database" {
  count                   = 2
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 20)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-database-${count.index + 1}" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "lab" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.lab]
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab.id
  }
}
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
# Banco isolado sem rota padrão para a internet.
resource "aws_route_table" "database" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_security_group" "node" {
  for_each    = toset(["vpn", "web", "wazuh"])
  name_prefix = "${local.name}-${each.key}-"
  description = "Regras explicitas para ${each.key} do laboratorio final"
  vpc_id      = aws_vpc.lab.id
}
resource "aws_security_group" "database" {
  name_prefix = "${local.name}-db-"
  description = "MySQL somente a partir da aplicacao"
  vpc_id      = aws_vpc.lab.id
}
resource "aws_vpc_security_group_ingress_rule" "vpn" {
  security_group_id = aws_security_group.node["vpn"].id
  ip_protocol       = "udp"
  from_port         = 1194
  to_port           = 1194
  cidr_ipv4         = var.administrator_cidr
}
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each                     = toset(["web", "wazuh"])
  security_group_id            = aws_security_group.node[each.key].id
  referenced_security_group_id = aws_security_group.node["vpn"].id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}
resource "aws_vpc_security_group_ingress_rule" "web" {
  security_group_id = aws_security_group.node["web"].id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "database" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.node["web"].id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}
locals {
  wazuh_ingress = {
    web_events = { source = "web", port = 1514 }
    web_enroll = { source = "web", port = 1515 }
    vpn_events = { source = "vpn", port = 1514 }
    vpn_enroll = { source = "vpn", port = 1515 }
    dashboard  = { source = "vpn", port = 443 }
    api        = { source = "vpn", port = 55000 }
  }
}
resource "aws_vpc_security_group_ingress_rule" "wazuh" {
  for_each                     = local.wazuh_ingress
  security_group_id            = aws_security_group.node["wazuh"].id
  referenced_security_group_id = aws_security_group.node[each.value.source].id
  ip_protocol                  = "tcp"
  from_port                    = each.value.port
  to_port                      = each.value.port
}
resource "aws_vpc_security_group_egress_rule" "https" {
  for_each          = aws_security_group.node
  security_group_id = each.value.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Repositorios, SSM e APIs AWS por TLS"
}
resource "aws_vpc_security_group_egress_rule" "apt" {
  for_each          = aws_security_group.node
  security_group_id = each.value.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Repositorios Ubuntu com pacotes assinados"
}
resource "aws_vpc_security_group_egress_rule" "vpn_private" {
  for_each          = toset(["22", "55000"])
  security_group_id = aws_security_group.node["vpn"].id
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_ipv4         = local.vpc_cidr
}
resource "aws_vpc_security_group_egress_rule" "wazuh" {
  for_each          = { web_events = { node = "web", port = 1514 }, web_enroll = { node = "web", port = 1515 }, vpn_events = { node = "vpn", port = 1514 }, vpn_enroll = { node = "vpn", port = 1515 } }
  security_group_id = aws_security_group.node[each.value.node].id
  ip_protocol       = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_ipv4         = "${local.wazuh_ip}/32"
}
resource "aws_vpc_security_group_egress_rule" "database" {
  security_group_id            = aws_security_group.node["web"].id
  referenced_security_group_id = aws_security_group.database.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}
