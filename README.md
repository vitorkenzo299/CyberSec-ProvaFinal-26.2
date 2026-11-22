# ABC Place — avaliação final de Cibersegurança 2026.2

**Grupo 09: Vitor, Artur Cruz e Daniel Juho.** A avaliação consolida e evolui os roteiros 1 a 4 do mesmo projeto ABC Place: identidade e acesso, análise de riscos, Wazuh, CloudWatch, Cloudflare e VPN.

**Aplicação atual:** [catálogo ABC Place em WordPress/WooCommerce](https://d3hc8whbcpdvtd.cloudfront.net).

A infraestrutura nova é um ambiente de evolução separado na conta institucional. O domínio `abcplace.blog.br`, o WordPress e os servidores dos roteiros anteriores permanecem preservados. Não houve alteração do DNS, peering, migração de clientes/pedidos ou substituição da loja antiga. A implementação demonstra os controles da evolução com três produtos sintéticos, sem pagamentos ou dados pessoais.

## Entrega

- [Relatório PDF](entrega/Relatorio_Final_Ciberseguranca.pdf) e [Word editável](entrega/Relatorio_Final_Ciberseguranca.docx)
- [Apresentação de 12 slides](entrega/Apresentacao_Executiva.pptx) e [PDF](entrega/Apresentacao_Executiva.pdf)
- [Matriz de riscos em Excel](entrega/Matriz_de_Riscos.xlsx): 14 IDs, escala original 4×4, fonte original e correspondência aos três níveis da avaliação final
- [Fotos e evidências completas](entrega/Evidencias_Completas.zip), [índice](evidencias/INDICE.md) e [manifesto SHA-256](evidencias/manifesto.json)
- [Roteiro de fala para os três integrantes](docs/roteiro-apresentacao.md)
- [Ligação com os roteiros anteriores](docs/mapeamento-dos-roteiros.md)

## Continuidade e resultados

| Base dos roteiros | Evolução demonstrada na avaliação |
| --- | --- |
| R1: IAM, EC2 e publicação Apache/HTTPS | SSO nominal, roles de serviço, consulta de menor privilégio e administração privada |
| R2: WordPress/WooCommerce, seis ameaças e sete fragilidades | Mesma plataforma e 14 cenários originais; controles e residual reavaliados |
| R3: Wazuh com Web/Database, FIM e análise de logs | Wazuh privado; agentes Web/VPN; eventos 554/550/553 também na árvore WordPress |
| R4: CloudWatch/SNS, rate limit Cloudflare e OpenVPN | CloudWatch e AWS WAF na nova VPC; VPN, logs de bloqueio e separação de rede testados |

WordPress 7.1.5, WooCommerce 11.3.1 e PHP 8.3.6 foram observados no servidor novo. A integridade do núcleo e do WooCommerce passou na comparação oficial. O usuário `abcplace_web` possui apenas SELECT/INSERT/UPDATE/DELETE no schema `abcplace_wp`; ele não tem privilégios de administração do RDS. TLS rejeitou CA incorreta e nome de servidor inválido. O catálogo técnico anterior mantém seu usuário separado com SELECT somente.

A varredura WordPress ZAP 2.17.0 concluiu em 100%, com fila passiva zerada: 1.228 mensagens, 16 URLs, 0 alertas High/Medium/Low e 54 informativos (duas regras). O relatório e a análise desses registros foram preservados. O scan anterior do catálogo Python permanece identificado como outro escopo.

**Risco residual:** seis cenários continuam altos (R01, R03, R06, R07, R10 e R14), com controles parciais, justificativa e ação proposta. Os oito demais são moderados. As estimativas não representam probabilidades medidas ou aprovação para produção. O kernel em triagem agora é **R03**, seguindo o ID da matriz do Roteiro 2.

## Operação

- [Arquitetura e limites](docs/arquitetura.md)
- [Matriz e justificativas](docs/matriz-de-riscos.md)
- [Procedimentos de acesso e pós-instalação](docs/operacao.md)
- [Consumo e encerramento](docs/custos-e-implantacao.md)
- [Status](docs/status.md) e [versões/fontes](docs/versoes-e-fontes.md)

Os quatro servidores e as regras dos nove grupos de segurança anteriores foram comparados e preservados nos campos avaliados. Segredos, perfil VPN e estado Terraform ficam fora do Git. A cobertura institucional não implica gratuidade ou bloqueio automático de gastos. Os recursos novos continuam ativos para a apresentação.
