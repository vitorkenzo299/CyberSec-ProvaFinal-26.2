# Índice das evidências

Grupo 09: Vitor, Artur Cruz e Daniel Juho. Coletas em 21/11/2026 no horário de Brasília; algumas aparecem como 22/11 em UTC. Os JSONs indicam horário UTC. Algumas telas mostram America/Sao_Paulo (UTC−03:00). Todas as fotos abaixo pertencem ao ambiente desta avaliação, exceto a captura inicial identificada como baseline anterior, usada somente para comprovar preservação.

| Código | Controle | Fontes principais |
| --- | --- | --- |
| EV01 | Arquitetura AWS | `atuais/20261121T223109Z/instancias.json`, `banco.json`, `sub-redes.json`, `rotas.json`; telas `aws-ec2-novas`, `aws-vpc`, `aws-rds` |
| EV02 | Identidades | `atuais/iam-observer.json`, `iam-simulacao.json`; `readonly_check` e agentes em `wazuh-eventos.json` |
| EV03 | Rede e hardening | `atuais/20261121T223109Z/security-groups.json`; telas `aws-sg-banco`, `aws-sg-web`, `aws-sg-vpn`; saídas SSH em `vpn-before-during.json`; `atuais/network-negative.json` e `servicos-finais.json` |
| EV04 | VPN | `atuais/vpn-before-during.json`, `vpn-after.json`, `wordpress/vpn-apos-revisao.json`; `registros/vpn-registro.html` e tela correspondente |
| EV05 | Wazuh e inventário | `atuais/wazuh-eventos.json`; telas `wazuh-overview`, `wazuh-vulnerabilidades` |
| EV06 | Alertas controlados | `atuais/ssh-negative-test.json`, `wazuh-eventos.json`; telas `wazuh-fim-eventos`, `wazuh-fim`, `wazuh-ssh-5712` e `wazuh-threat-hunting` |
| EV07 | Aplicação e WAF | `atuais/waf-test.json`; `20261121T223109Z/cloudfront.json`, `waf-configuracao.json`; telas `site-aws` (catálogo técnico anterior ao WordPress), `aws-waf-regras` |
| EV08 | SQLi e taxa | `atuais/waf-rate.json`, `waf-logs.json`; telas `aws-waf-trafego`, `aws-waf-overview`; registro técnico `waf-registro` |
| EV09 | Auditoria | `atuais/20261121T223109Z/auditoria-status.json`, `alarmes.json`; telas `aws-cloudwatch`, `aws-trilha` |
| EV10 | ZAP do catálogo Python | `atuais/varredura/zap-result.json`, `zap-coverage.json`, `zap-report.html`; telas `zap-registro` e `zap-relatorio-original` |
| EV11 | Recuperação do catálogo técnico | `atuais/backup-restore.json`, `backup-lifecycle.json`; registro técnico `backup-registro` |
| EV12 | Cobertura e preservação | `atuais/cobertura-e-preservacao.json`, `preservacao-anterior.json`; tela `aws-ec2-anterior-baseline` |
| EV13 | Triagem do kernel | `atuais/pacotes-atualizacoes.json`, `triagem-kernel.json`, `wazuh-eventos.json`; fonte [Canonical](https://ubuntu.com/security/CVE-2026-98367) |

## Complemento da continuidade

| Código | Controle | Fontes principais |
| --- | --- | --- |
| EV14 | Continuidade dos roteiros | `continuidade/fontes.json`, `matriz-original.json`, `linha-do-tempo.json` e `correspondencia-ids.json` |
| EV15 | WordPress/WooCommerce | `wordpress/verificacao.json`, `http-publico.json`, `waf-logs.json`, `fim-eventos.json`, `implantacao.json`, `permissao-temporaria.json` e telas em `wordpress/telas` |
| EV16 | Scan WordPress | `wordpress/varredura` (final e `inicial`), `triagem-informativos.json` e `reteste-hardening.json` |

Os nomes das telas correspondem a arquivos `.png` em `atuais/telas`. Os relatórios HTML técnicos estão em `atuais/registros`, e as fontes numéricas em JSON. Esses registros gerados têm identificação própria e não substituem os screenshots reais. O IPv4 pessoal do operador é removido da cópia pública de regras; a restrição /32 é preservada. O número da conta é mascarado nos JSONs de inventário, mas pode aparecer em telas do console.

## Limites das provas

- EV10 (Python) não emitiu alertas; EV16 (WordPress) emitiu 54 informativos e nenhum High/Medium/Low. O inventário do kernel permanece em triagem.
- HTTP 403 isolado não prova a regra acionada. A correlação do WAF está em `waf-logs.json`.
- Três registros restaurados não definem RPO/RTO de produção.
- A comparação do ambiente anterior cobre os campos e regras listados no arquivo, não cada metadado da conta.
- As evidências locais em `locais` validam a aplicação e a configuração de forma independente, com provedores Terraform simulados.

Integridade: [manifesto.json](manifesto.json), com SHA-256 e tamanho de cada evidência. Capturas e resultados foram conservados sem senhas, chaves ou perfis de acesso.

## Verificações finais

O reteste ZAP está nos arquivos principais de `atuais/varredura`; a primeira execução foi preservada em `inicial`. A comparação registra 37 respostas 501 na primeira execução e 37 respostas 405 na final. A final contém duas entradas HTTP de status 0, não contadas como sucesso. Foram executadas 53 regras ativas e 61 passivas; a regra 20020 apareceu somente na primeira execução após atualização automática do complemento. O HTML nativo também mostra estatísticas auxiliares de download do driver pelo próprio ZAP; o alvo da varredura ativa foi apenas a origem local encaminhada.

`terraform-convergencia.json` registra o plano final sem mudanças. `servicos-finais.json` comprova os serviços ativos e o hash do aplicativo implantado. `capturas.json` lista as fotos preservadas. `qualidade-entrega.json` descreve a validação dos arquivos de entrega.


## Continuidade ABC Place e revisão do grupo (snapshot histórico anterior à integração final)

O material atual consolida os roteiros 1–4, preservando os 14 IDs da matriz original. A autoria é de Vitor, Artur Cruz e Daniel Juho. A matriz original usa quatro níveis; a revisão fornece também a leitura de três níveis pedida na final. Os documentos de origem foram apenas lidos e identificados por hash, sem republicar anexos que possam conter detalhes de acesso.

As capturas em `atuais/telas` pertencem à primeira implantação da avaliação, incluindo o catálogo Python. As capturas `wordpress/telas` demonstram a evolução para WordPress/WooCommerce. A imagem inicial do scan WordPress e seus arquivos originais foram mantidos; o reteste final está na raiz de `wordpress/varredura`. O primeiro scan teve uma resposta 500 no acesso direto à pasta do tema. As guardas ABSPATH dos arquivos próprios corrigiram esse caminho; o reteste final não registrou 5xx. As sete mensagens de status 0 não são contadas como sucesso.

O HTML ZAP agrupa 54 instâncias informativas em duas regras. O JSON conserva as 52 de User Agent Fuzzer e as duas reflexões de atributo. A revisão dirigida de navegador não executou os marcadores de teste. O download auxiliar de driver do próprio ZAP também aparece nas estatísticas nativas; o contexto ativo foi limitado à origem local encaminhada.

A prova de restauração EV11 antecede WordPress e valida somente o catálogo técnico. Na coleta histórica de 21/11, os alarmes novos e o subdomínio final ainda não estavam integrados. EV17–EV23 abaixo documentam as alterações posteriores de 22/11; o domínio legado e a infraestrutura anterior foram preservados. `wordpress/vpn-apos-revisao.json` comprova o encerramento dos clientes locais e o catálogo público ainda disponível.

Os IDs gravados em registros históricos da primeira revisão são localizados por `continuidade/correspondencia-ids.json`; o antigo R05 do kernel corresponde ao R03 atual. `continuidade/qualidade-versao-anterior.json` pertence ao commit 476b779 e seus hashes se referem aos arquivos daquele commit, não aos entregáveis revisados. O recibo atual é `atuais/qualidade-entrega.json`.


## Conferência operacional adicional

`revisao-final/` contém nova consulta de saúde AWS, respostas públicas, teste limitado da Cloudflare com recuperação, conexão/desconexão VPN, serviços internos, recebimento de logs e conferência dos hashes dos arquivos revisados. A conferência de 21/11 às 22h21–22h25 (Brasília) confirma operação atual, mantendo explícitas as pendências em `resumo.json`. Ela não altera as datas ou o escopo dos testes anteriores.


## Integração final verificada — 22/11/2026

As linhas e capturas antigas foram mantidas como histórico. As evidências abaixo descrevem o estado integrado mais recente e prevalecem sobre observações anteriores que indicavam pendências de Cloudflare, SNS, TLS ou restauração.

| Código | Resultado atual | Evidência e capturas |
| --- | --- | --- |
| EV17 | Cloudflare → CloudFront/AWS WAF → origem HTTPS; DNS legado preservado | `integracao/borda-testes.json`, `integracao/cloudflare-configuracao.json`, `integracao/preservacao.json`; `integracao/telas/cloudflare-dns.png`, `aws-waf-integrado.png`, `aws-cloudfront-origem.png` |
| EV18 | Oito alarmes ligados ao SNS existente; ciclo ALARM/OK de rede confirmado pelo usuário; estado final OK | `integracao/notificacoes.json`; captura atual `integracao/telas/aws-cloudwatch-integrado.png` |
| EV19 | MFA de Vitor observado no IAM Identity Center; Cloudflare por e-mail | `integracao/mfa.json`; `integracao/telas/aws-mfa-operador.png`, `cloudflare-mfa.png` |
| EV20 | Restauração WordPress: 52 tabelas, 8.808 arquivos, hashes e loja/busca 200 | `integracao/recuperacao-wordpress.json`; registro técnico `integracao/telas/backup-registro.png` |
| EV21 | Triagem do kernel em três hosts; hardening compensatório, sem patch provado; R03 continua alto | `integracao/kernel-triagem.json`, `hardening-kernel.json`; registro `integracao/telas/kernel-registro.png` |
| EV22 | ZAP WordPress concluído; 0 High/Medium/Low, 54 informativos; painel e checkout fora do escopo | `integracao/varredura/`; `integracao/telas/zap-final.png` |
| EV23 | Plano Terraform sem mudanças; sessão de alteração usou AdministratorAccess; quatro servidores e nove SGs avaliados preservados | `integracao/terraform-convergencia.json`, `integracao/preservacao.json`; registros sanitizados `integracao/telas/terraform-convergencia.png`, `aws-sessao-registro.png` |

`arquitetura.png` é diagrama explicativo. Capturas `backup-registro.png`, `kernel-registro.png`, `terraform-convergencia.png` e `aws-sessao-registro.png` são registros técnicos gerados a partir dos JSONs e identificados como tais, não imagens de console. `site-final.png`, `cloudflare-dns.png`, `cloudflare-mfa.png`, `aws-mfa-operador.png`, `aws-waf-integrado.png`, `aws-cloudfront-origem.png`, `aws-cloudwatch-integrado.png` e `wazuh-fim-atual.png` são capturas visuais do ambiente. Os arquivos `aws-waf-action-totals-recorte.png` e `zap-resumo-recorte.png` são recortes derivados das capturas completas correspondentes; `aws-sessao-registro-recorte.png` é recorte do registro técnico gerado. Os originais permanecem preservados. `aws-alarmes-atuais.png` é uma visualização anterior de consulta com limitação de permissão e não é usada como prova do estado atual de SNS.

A implantação não criou novos EC2/RDS nem alterou meio de pagamento pessoal. CloudWatch, logs e aproximadamente 71,6 MB em duas versões do backup podem gerar custos institucionais. A conta não foi limitada por orçamento e a fatura não foi consultada. Cinco riscos residuais permanecem altos: R01, R03, R06, R07 e R10.
