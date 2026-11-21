variable "expected_account_id" {
  type        = string
  description = "Conta destinada ao laboratório novo. Nenhuma conta é assumida por padrão."
  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Informe os 12 dígitos da conta escolhida."
  }
}
variable "operator_name" {
  type        = string
  description = "Usuário nominal para SSH. Não utilizar root, admin ou ubuntu."
  default     = "vitor"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{1,20}$", var.operator_name)) && !contains(["root", "admin", "ubuntu"], var.operator_name)
    error_message = "Use um nome nominal válido."
  }
}
variable "ssh_public_key" {
  type        = string
  description = "Somente a chave pública nova do operador. Nunca informar chave privada."
  validation {
    condition     = can(regex("^ssh-(ed25519|rsa) [A-Za-z0-9+/=]+", var.ssh_public_key))
    error_message = "Forneça uma chave pública OpenSSH."
  }
}
variable "administrator_cidr" {
  type        = string
  description = "IPv4 público atual do operador, restrito a /32, para UDP 1194."
  validation {
    condition     = can(cidrnetmask(var.administrator_cidr)) && endswith(var.administrator_cidr, "/32") && var.administrator_cidr != "0.0.0.0/32"
    error_message = "A origem da VPN deve ser um IPv4 específico com /32."
  }
}
variable "project_prefix" {
  type        = string
  default     = "cyberfinal262"
  description = "Prefixo exclusivo deste laboratório."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,15}$", var.project_prefix))
    error_message = "Use de 3 a 16 caracteres minúsculos, números ou hífen."
  }
}
variable "domain_name" {
  type        = string
  default     = null
  description = "Domínio novo opcional. Necessário com ACM para exigir TLS 1.2 no CloudFront."
}
variable "acm_certificate_arn" {
  type        = string
  default     = null
  description = "Certificado ACM já validado em us-east-1 para o domínio informado."
  validation {
    condition     = var.acm_certificate_arn == null ? true : can(regex("^arn:aws:acm:us-east-1:[0-9]{12}:certificate/", var.acm_certificate_arn))
    error_message = "O certificado do CloudFront deve estar em us-east-1."
  }
}
variable "protect_database" {
  type        = bool
  default     = true
  description = "Protege o RDS contra exclusão. Desativar deliberadamente ao encerrar o laboratório."
}
variable "wazuh_installer_sha256" {
  type        = string
  description = "SHA-256 revisado do instalador oficial Wazuh 4.14."
  validation {
    condition     = can(regex("^[a-f0-9]{64}$", var.wazuh_installer_sha256))
    error_message = "Informe o SHA-256 do instalador oficial."
  }
}
