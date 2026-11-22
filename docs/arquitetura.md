# Arquitetura integrada da ABC Place

A avaliação do Grupo 09 usa a VPC de evolução `10.62.0.0/16` em us-east-1, com seis sub-redes em duas zonas. A loja final é servida em `https://final.abcplace.blog.br`.

![Arquitetura da integração atual](arquitetura.svg)

## Caminho de acesso

Internet → Cloudflare → CloudFront/AWS WAF → VPC Origin sobre HTTPS/TLS 1.2 → Nginx/PHP-FPM/WordPress/WooCommerce → RDS MySQL 8.4 por TLS.

Cloudflare mantém seu plano Free, proxy ativo no CNAME novo e TLS mínimo 1.2. O modo Full Strict aplica-se ao subdomínio final. CloudFront usa política TLS 1.2 e a origem privada aceita HTTPS. O ACM cobre o domínio CloudFront; o certificado público Let’s Encrypt da origem foi renovado em dry-run, sem substituição do certificado ativo durante o teste.

A AWS WAF tem cinco regras, incluindo origens oficiais Cloudflare, assinaturas gerenciadas SQLi e limites de requisição. Os logs correlacionam o bloqueio do probe, SQLi e bypass. Cloudflare também limita `/wp-admin`. Esses ensaios não medem DDoS distribuído ou capacidade máxima.

## Rede, identidade e dados

Web `10.62.10.10` e Wazuh `10.62.10.20` não têm IP público. Um único NAT Gateway fornece saída. OpenVPN aceita UDP 1194 da origem `/32`; SSH nominal e administração Wazuh são privados. RDS MySQL 8.4 é privado, criptografado, Single-AZ, com backup de sete dias e proteção contra exclusão.

WordPress usa schema `abcplace_wp` e usuário `abcplace_web` com SELECT/INSERT/UPDATE/DELETE somente nesse schema. A conexão RDS valida CA e hostname. O código é protegido contra escrita pelo serviço; uploads não executam PHP e `wp-config.php` fica restrito a root:www-data. Checkout comercial, cadastro e dados pessoais não estão em uso.

A sessão usada para alterar AWS foi `AWSReservedSSO_AdministratorAccess`. A função `observer` separada foi usada para consulta, mas não comprova privilégio mínimo de implantação. O dispositivo MFA de Vitor foi observado no portal institucional; root, demais integrantes e a política global não foram auditados. Essa pendência mantém R01 alto.

## Monitoramento e recuperação

Wazuh recebe agentes Web e VPN. O FIM da árvore WordPress registrou eventos de criação, modificação e remoção. RDS gerenciado não recebe agente de sistema operacional; sua observação depende dos controles e logs AWS. CloudWatch, CloudTrail e VPC Flow Logs ficam centralizados. Oito alarmes estão ligados ao tópico SNS existente; o teste de rede confirmou ALARM e OK por e-mail, e os oito alarmes retornaram a OK.

A restauração WordPress validou 52 tabelas e 8.808 arquivos por hash, com loja e busca HTTP 200 em cópia isolada. Duas versões do backup AES-256-GCM/SSE-S3 ficaram no bucket privado versionado. Não há rotina diária, teste de perda integral da conta ou SLA comercial. RPO/RTO, cópia independente contra ransomware e capacidade comercial continuam pendentes.

## Relação com a infraestrutura anterior

O subdomínio `final` foi adicionado à zona existente. Os registros DNS de apex, `www` e monitoramento, quatro servidores anteriores e regras dos nove Security Groups comparados permaneceram iguais nos campos avaliados. Não houve peering ou migração de clientes, pedidos, uploads ou configuração antiga. O catálogo Python continua como módulo técnico histórico; a aplicação principal da avaliação é WordPress/WooCommerce.

## Limites

A evolução possui um Web, um NAT e RDS Single-AZ. Seis sub-redes em duas zonas não tornam os serviços redundantes. Cinco riscos seguem altos: R01, R03, R06, R07 e R10. R03 mantém achados do kernel; painel/plugins autenticados, checkout, ransomware, dados reais e resposta a vazamento não foram totalmente validados. A arquitetura é uma demonstração acadêmica, não uma aprovação para produção.

Os recursos continuam ativos na conta institucional. Nenhum pagamento pessoal foi modificado nem novos EC2/RDS foram criados. Backups versionados, métricas e logs podem gerar custo institucional; a fatura não foi consultada e não há teto automático.
