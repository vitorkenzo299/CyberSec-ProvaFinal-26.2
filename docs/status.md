# Status da avaliação final ABC Place

**Grupo 09:** Vitor, Artur Cruz e Daniel Juho. Revisão de 22/11/2026. Os horários de execução estão preservados em UTC nos JSONs; capturas de tela podem mostrar Brasília (UTC−03:00).

| Item | Resultado atual |
| --- | --- |
| Continuidade | Roteiros 1–4 mapeados; caso ABC Place e 14 IDs do Roteiro 2 preservados |
| Loja | WordPress/WooCommerce no catálogo acadêmico, três produtos sintéticos, em `https://final.abcplace.blog.br` |
| Borda | Cloudflare → CloudFront/AWS WAF → origem privada HTTPS; TLS 1.2; SQLi, bypass e limites retestados |
| VPN | Acesso administrativo privado, SSH nominal; acesso antes/durante/depois da VPN conferido |
| Wazuh | Dois agentes ativos (Web e VPN), logs centralizados e FIM da árvore WordPress com eventos comprovados |
| Alertas | Oito alarmes integrados ao SNS existente; ciclo de rede ALARM/OK confirmado pelo usuário; todos retornaram a OK |
| Recuperação | Restauração integral WordPress: 52 tabelas, 8.808 arquivos, hashes conferidos, catálogo e busca HTTP 200 |
| Varredura | ZAP WordPress 2.17.0: 100%, 1.232 registros HTTP e 16 formas de URL (12 endpoints no sumário HTML), 0 High/Medium/Low e 54 informativos; painel/checkout fora do escopo |
| Infraestrutura anterior | Quatro servidores, nove Security Groups e registros legados avaliados sem mudança nos campos comparados |
| Plano Terraform | Plano final sem mudanças e sem ações destrutivas; nenhum apply necessário |
| Custo | Conta institucional e Cloudflare Free; sem meio de pagamento pessoal alterado e sem novo EC2/RDS. Métricas, logs e cópias versionadas ainda podem gerar cobrança institucional |

A matriz mantém a escala e os 14 IDs originais. **Cinco riscos continuam altos:** R01, R03, R06, R07 e R10. R01 permanece alto porque as alterações AWS usaram `AWSReservedSSO_AdministratorAccess`; o menor privilégio de implantação não foi comprovado. R03 mantém achados de kernel sem patch demonstrado. Os outros riscos altos têm lacunas em testes autenticados, ransomware/cópia independente e proteção de dados/resposta a vazamento.

## Limites de uso

O ambiente comprova controles para uma demonstração acadêmica; não é certificado para operação comercial. A loja não contém clientes, pedidos ou pagamentos reais. Plugins e painel autenticados, resposta a ransomware, RPO/RTO, capacidade e redundância comercial permanecem fora do teste. Root, MFA dos demais integrantes e política global institucional não foram auditados. O Wazuh usa PKI privada dentro da VPN.

Os serviços permanecem ativos na conta institucional. A revisão não consultou a fatura e não configurou teto automático. A conta institucional não significa custo zero. Não foram excluídos recursos nem alterado o domínio legado.

## Próximas ações

1. Substituir `AdministratorAccess` por uma função de implantação com permissões mínimas revisadas antes de novos provisionamentos.
2. Acompanhar correção do kernel e repetir inventário/OVAL após atualização aplicável.
3. Planejar testes autenticados, prevenção e resposta a ransomware, dados pessoais e recuperação com RPO/RTO aprovados antes de qualquer uso comercial.
4. Acompanhar consumo institucional e decidir o encerramento apenas dos recursos da final com autorização própria; preservar o legado e as evidências.
