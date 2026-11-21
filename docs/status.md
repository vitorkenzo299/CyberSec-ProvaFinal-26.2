# Situação da entrega

Atualização em 21 de novembro de 2026. Autor e apresentador: Vitor.

O ambiente novo foi criado e testado. Os arquivos finais estão em `entrega`, e as provas práticas em `evidencias/atuais`. O relatório possui 14 páginas e a apresentação tem 12 slides, com notas para fala individual. Word, PowerPoint, Excel e as evidências são editáveis ou consultáveis fora da nuvem.

## Concluído

- VPC nova com seis sub-redes, três EC2, RDS privado e CloudFront com VPC Origin e WAF.
- VPN funcional, SSH nominal, root e senha desativados, firewalls e regras de rede restritas.
- Função AWS observer e usuário Wazuh vitor somente de consulta, com negações verificadas.
- Dois agentes Wazuh ativos, três eventos FIM e alerta 5712 de força bruta controlada.
- WAF com bloqueios do probe, SQLi e taxa confirmados nos logs.
- ZAP 2.17.0 concluído na origem privada sem alertas no escopo testado.
- Snapshot RDS restaurado, dados comparados e cópia temporária removida.
- Comparação de preservação das quatro instâncias e dos nove SG anteriores.

## Pendências de segurança registradas

1. R05 continua alto: triar as correlações High e Critical de linux-aws. Apt não ofereceu atualizações e uma amostra já indica correspondência imprecisa do metapacote. Essa amostra não fecha todo o inventário.
2. Domínio e ACM para exigir TLS 1.2 na borda e TLS no caminho até a origem.
3. Confirmação de MFA do SSO e teste de destinatário externo para alertas.
4. Redundância de Web e NAT, RDS Multi-AZ e metas de RPO/RTO antes de produção.
5. Acompanhamento do consumo institucional e encerramento somente dos recursos novos ao fim do uso autorizado.

Essas limitações estão na matriz, no relatório e nos slides. Nenhum resultado foi fabricado para indicar ausência de riscos.
