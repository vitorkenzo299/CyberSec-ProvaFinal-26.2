# Índice das evidências

Autor: Vitor. Coletas em 21/11/2026. Os JSONs indicam horário UTC. Algumas telas mostram America/Sao_Paulo (UTC−03:00). Todas as fotos abaixo pertencem ao ambiente desta avaliação, exceto a captura inicial identificada como baseline anterior, usada somente para comprovar preservação.

| Código | Controle | Fontes principais |
| --- | --- | --- |
| EV01 | Arquitetura AWS | `atuais/20261121T223109Z/instancias.json`, `banco.json`, `sub-redes.json`, `rotas.json`; telas `aws-ec2-novas`, `aws-vpc`, `aws-rds` |
| EV02 | Identidades | `atuais/iam-observer.json`, `iam-simulacao.json`; `readonly_check` e agentes em `wazuh-eventos.json` |
| EV03 | Rede e hardening | `atuais/20261121T223109Z/security-groups.json`; telas `aws-sg-banco`, `aws-sg-web`, `aws-sg-vpn`; saídas SSH em `vpn-before-during.json`; `atuais/network-negative.json` e `servicos-finais.json` |
| EV04 | VPN | `atuais/vpn-before-during.json`, `vpn-after.json`; `registros/vpn-registro.html` e tela correspondente |
| EV05 | Wazuh e inventário | `atuais/wazuh-eventos.json`; telas `wazuh-overview`, `wazuh-vulnerabilidades` |
| EV06 | Alertas controlados | `atuais/ssh-negative-test.json`, `wazuh-eventos.json`; telas `wazuh-fim-eventos`, `wazuh-fim`, `wazuh-ssh-5712` e `wazuh-threat-hunting` |
| EV07 | Aplicação e WAF | `atuais/waf-test.json`; `20261121T223109Z/cloudfront.json`, `waf-configuracao.json`; telas `site-aws`, `aws-waf-regras` |
| EV08 | SQLi e taxa | `atuais/waf-rate.json`, `waf-logs.json`; telas `aws-waf-trafego`, `aws-waf-overview`; registro técnico `waf-registro` |
| EV09 | Auditoria | `atuais/20261121T223109Z/auditoria-status.json`, `alarmes.json`; telas `aws-cloudwatch`, `aws-trilha` |
| EV10 | ZAP | `atuais/varredura/zap-result.json`, `zap-coverage.json`, `zap-report.html`; telas `zap-registro` e `zap-relatorio-original` |
| EV11 | Recuperação RDS | `atuais/backup-restore.json`, `backup-lifecycle.json`; registro técnico `backup-registro` |
| EV12 | Cobertura e preservação | `atuais/cobertura-e-preservacao.json`, `preservacao-anterior.json`; tela `aws-ec2-anterior-baseline` |
| EV13 | Triagem do kernel | `atuais/pacotes-atualizacoes.json`, `triagem-kernel.json`, `wazuh-eventos.json`; fonte [Canonical](https://ubuntu.com/security/CVE-2026-98367) |

Os nomes das telas correspondem a arquivos `.png` em `atuais/telas`. Os relatórios HTML técnicos estão em `atuais/registros`, e as fontes numéricas em JSON. Esses registros gerados têm identificação própria e não substituem os screenshots reais. O IPv4 pessoal do operador é removido da cópia pública de regras; a restrição /32 é preservada. O número da conta é mascarado nos JSONs de inventário, mas pode aparecer em telas do console.

## Limites das provas

- ZAP sem alertas se refere à aplicação e às regras executadas. O inventário do kernel permanece em triagem.
- HTTP 403 isolado não prova a regra acionada. A correlação do WAF está em `waf-logs.json`.
- Três registros restaurados não definem RPO/RTO de produção.
- A comparação do ambiente anterior cobre os campos e regras listados no arquivo, não cada metadado da conta.
- As evidências locais em `locais` validam a aplicação e a configuração de forma independente, com provedores Terraform simulados.

Integridade: [manifesto.json](manifesto.json), com SHA-256 e tamanho de cada evidência. Capturas e resultados foram conservados sem senhas, chaves ou perfis de acesso.

## Verificações finais

O reteste ZAP está nos arquivos principais de `atuais/varredura`; a primeira execução foi preservada em `inicial`. A comparação registra 37 respostas 501 na primeira execução e 37 respostas 405 na final. A final contém duas entradas HTTP de status 0, não contadas como sucesso. Foram executadas 53 regras ativas e 61 passivas; a regra 20020 apareceu somente na primeira execução após atualização automática do complemento. O HTML nativo também mostra estatísticas auxiliares de download do driver pelo próprio ZAP; o alvo da varredura ativa foi apenas a origem local encaminhada.

`terraform-convergencia.json` registra o plano final sem mudanças. `servicos-finais.json` comprova os serviços ativos e o hash do aplicativo implantado. `capturas.json` lista as fotos preservadas. `qualidade-entrega.json` descreve a validação dos arquivos de entrega.
