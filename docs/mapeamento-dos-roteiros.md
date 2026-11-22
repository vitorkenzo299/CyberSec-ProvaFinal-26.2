# Continuidade dos roteiros da ABC Place

**Grupo 09:** Vitor, Artur Cruz e Daniel Juho. Esta avaliação final continua o mesmo caso ABC Place e evolui sua plataforma WordPress/WooCommerce. Os materiais dos roteiros anteriores foram consultados e identificados por hash; os arquivos de origem permaneceram sem alteração.

| Etapa | Base consultada | Integração demonstrada | Limite mantido |
| --- | --- | --- | --- |
| Roteiro 1 | IAM, EC2, Apache e HTTPS | SSO nominal, MFA observado para Vitor, SSH nominal e acesso privado por VPN | As alterações desta avaliação usaram `AWSReservedSSO_AdministratorAccess`; menor privilégio de implantação ainda precisa ser revisado. A instalação nova usa Nginx/PHP-FPM; o Apache antigo não foi convertido |
| Roteiro 2 | Seis ameaças, sete fragilidades e 14 riscos | Mesmos IDs e escala 4×4; pontuações residuais ligadas a provas atuais | Nove extremos e cinco altos eram o cenário original; as metas residuais antigas não eram resultados medidos |
| Roteiro 3 | Wazuh, agentes, FIM e análise de logs | Wazuh privado, agentes Web/VPN, eventos FIM na árvore WordPress e logs AWS | RDS gerenciado usa logs e controles AWS, sem agente de sistema operacional. FIM não prova prevenção de ransomware |
| Roteiro 4 | CloudWatch, SNS, Cloudflare e OpenVPN | Cloudflare também protege o subdomínio final; AWS WAF integrado; oito alarmes ligados ao SNS existente; VPN retestada | O ciclo ALARM/OK foi provocado e confirmado para rede. Os outros alarmes não foram acionados individualmente |
| Avaliação final | WordPress/WooCommerce na evolução em VPC | Restauração completa, scan recente, TLS de borda/origem e preservação comparada | Sem migração comercial, dados reais ou substituição dos recursos anteriores |

O domínio `final.abcplace.blog.br` é servido por Cloudflare, CloudFront/AWS WAF e origem privada HTTPS. O CNAME novo foi adicionado. Os registros de apex, `www` e monitoramento, os quatro servidores anteriores e as regras avaliadas dos nove Security Groups não mudaram. A nova VPC permanece separada; não houve peering ou importação de pedidos/clientes.

A restauração integral atual pertence ao WordPress e está em EV20. O backup anterior do catálogo Python, EV11, continua registrado em seu escopo histórico. O fluxo SNS do Roteiro 4 também continua como evidência histórica; EV18 registra os alarmes integrados nesta avaliação e o ciclo atual de rede. A captura ZAP do catálogo Python, EV10, não representa o scan WordPress de EV22.

## Matriz e interpretação

A matriz original preserva os 14 riscos, a escala 1–4 e as metas históricas. Na revisão final, 1–2 é baixo, 3–6 moderado, 7–9 alto e acima de 9 extremo; na leitura final de três níveis, moderado corresponde a médio e alto/extremo a alto. São estimativas qualitativas, não frequências medidas.

A revisão tem cinco altos: R01, R03, R06, R07 e R10. R01 mantém pontuação alta porque foi usada a função AWS `AdministratorAccess` e não foi provado privilégio mínimo. MFA foi observado para Vitor; root, demais integrantes e política global não foram auditados. R03 recebeu hardening compensatório, sem que isso substitua patch de kernel.

## Organização do grupo

A autoria é do trio. A divisão de fala proposta é Artur Cruz nos slides 1–4, Vitor nos slides 5–8 e Daniel Juho nos slides 9–12. O registro técnico da sessão identifica Vitor; a apresentação não afirma configuração de contas próprias para os colegas nem atribui retroativamente cada tarefa.
