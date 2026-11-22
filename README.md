# ABC Place — avaliação final de Cibersegurança 2026.2

**Grupo 09: Vitor, Artur Cruz e Daniel Juho.** Esta entrega integra os roteiros 1–4 do mesmo caso ABC Place: identidade e acesso, análise de riscos, Wazuh, CloudWatch, Cloudflare, VPN e WordPress/WooCommerce.

**Loja final:** [final.abcplace.blog.br](https://final.abcplace.blog.br).

A evolução usa a conta AWS institucional e a zona Cloudflare existente. O novo subdomínio passa por Cloudflare, CloudFront/AWS WAF e origem privada HTTPS. Os registros anteriores, quatro servidores e Security Groups avaliados foram preservados. A loja contém três produtos sintéticos, sem checkout comercial ou dados pessoais.

## Entrega

- [Relatório PDF](entrega/Relatorio_Final_Ciberseguranca.pdf) e [Word editável](entrega/Relatorio_Final_Ciberseguranca.docx)
- [Apresentação de 12 slides](entrega/Apresentacao_Executiva.pptx) e [PDF](entrega/Apresentacao_Executiva.pdf)
- [Matriz de riscos](entrega/Matriz_de_Riscos.xlsx), com 14 cenários, pontuação original e residual, ações e provas
- [Evidências completas](entrega/Evidencias_Completas.zip), [índice](evidencias/INDICE.md) e [manifesto SHA-256](evidencias/manifesto.json)
- [Roteiro de fala](docs/roteiro-apresentacao.md), [mapeamento dos roteiros](docs/mapeamento-dos-roteiros.md), [status](docs/status.md) e [arquitetura](docs/arquitetura.md)

## Resultado técnico

Cloudflare e AWS WAF protegem o subdomínio final, HTTPS é exigido até a origem privada, a VPN restringe administração e o Wazuh registra alterações FIM. Oito alarmes estão ligados ao SNS existente; a notificação de rede ALARM/OK foi confirmada pelo usuário. A restauração do WordPress conferiu 52 tabelas, 8.808 arquivos e respostas HTTP 200 da loja e da busca. O scan ZAP final não encontrou achados High/Medium/Low no escopo público testado; painel, plugins autenticados e checkout não foram validados.

A matriz conserva 14 IDs: **cinco riscos permanecem altos** (R01, R03, R06, R07 e R10) e nove são moderados. R01 segue alto porque foi usada a função AWS `AdministratorAccess`; menor privilégio para implantação não foi comprovado. R03 mantém achados de kernel sem patch demonstrado. Os riscos de testes autenticados, ransomware, dados e resposta a incidentes também permanecem explícitos. A demonstração não é aprovação para produção.

## Custo e preservação

Não foi alterado nenhum meio de pagamento pessoal nem criado novo EC2/RDS; Cloudflare permanece no plano Free. A conta é institucional, mas não significa custo zero: as cópias versionadas no S3, métricas e logs podem gerar cobrança institucional. A fatura não foi consultada e não existe teto automático configurado. Os serviços permanecem ativos. Nenhum recurso antigo foi apagado.

Consulte [consumo e encerramento](docs/custos-e-implantacao.md) antes de pedir mudanças ou limpeza. Qualquer encerramento deve ser limitado aos recursos da avaliação e preservar o legado e as evidências.
