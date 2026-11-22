# Continuidade dos roteiros da ABC Place

Grupo 09: Vitor, Artur Cruz e Daniel Juho. Esta avaliação final é a evolução do mesmo caso ABC Place, cuja plataforma de negócio é WordPress/WooCommerce.

| Etapa | Base consultada | O que a final aproveita | Diferença e limite |
| --- | --- | --- | --- |
| Roteiro 1 | Relatório IAM/EC2/Apache e enunciado | Identidade nominal, roles temporárias, acesso e publicação Web | A implantação nova usa Ubuntu/Nginx/PHP-FPM; não se afirma que o Apache antigo foi convertido |
| Roteiro 2 | Apresentação e matriz v1.0 | Seis ameaças, sete fragilidades, mesmos 14 IDs e escala P×I de 1 a 4 | Nove extremos e cinco altos eram o cenário do caso. Residuais originais eram metas, não controles já implementados |
| Roteiro 3 | Relatório do grupo de 15/10/2026 | Wazuh, agentes, FIM, detecção SSH e análise de logs | No legado os agentes eram Web/Database; na VPC nova são Web/VPN. RDS gerenciado usa logs/controles AWS, sem agente de SO |
| Roteiro 4 | Relatório e provas de 16/11/2026 | CloudWatch, alertas, limitação de requisições e VPN | Cloudflare permanece no domínio legado. AWS WAF protege a distribuição nova. Os limites e janelas não são iguais |
| Final | Provas atuais de 21/11 em Brasília (algumas em 22/11 UTC) | WordPress/WooCommerce no Web privado, schema no RDS existente, WAF, VPN, identidades, scan e FIM recentes | Ambiente de evolução paralelo; sem alteração de DNS, peering ou migração integral |

O Roteiro 4 documentou recebimento de e-mails SNS de ALARM e OK no projeto anterior. Essa prova é histórica e válida para aquele fluxo. A entrega não a transforma em comprovação de destinatário configurado nos alarmes novos. O mesmo cuidado vale para testes, agentes e versões do Wazuh do Roteiro 3.

## Matriz e interpretação

O documento de origem foi lido sem alteração. `evidencias/continuidade/matriz-original.json` preserva os 14 registros e seus valores de origem; `fontes.json` registra nomes e hashes dos materiais consultados. A aba Original R2 mantém o cenário e as metas residuais da planilha anterior. A aba Riscos contém a revisão atual, e Tratamentos liga cada ID à prova e à próxima ação.

Escala original: 1–2 baixo, 3–6 moderado, 7–9 alto e >9 extremo. Para atender à leitura em três níveis da final, moderado corresponde a médio e alto/extremo a alto. P/I 1 corresponde a baixo, 2 a médio, 3–4 a alto, mantendo o número original para rastreabilidade. Não se atribuem frequências reais às estimativas.

O caso descreve WordPress/WooCommerce, checkout e dados de clientes. A implantação acadêmica atual habilita apenas catálogo sintético. Testes de catálogo não validam pagamentos, plugins autenticados, recuperação de pedidos ou uma migração em produção. Os cenários correspondentes permanecem limitados ou altos com justificativa.

## Organização do grupo

A autoria da entrega é do trio. A divisão de fala proposta é: Artur Cruz, slides 1–4; Vitor, slides 5–8; Daniel Juho, slides 9–12. As notas e o roteiro apresentam as transições. Os registros atuais de operação técnica identificam a sessão nominal Vitor; a capa não é usada como prova de que os três já tenham contas configuradas ou de contribuições individuais passadas.
