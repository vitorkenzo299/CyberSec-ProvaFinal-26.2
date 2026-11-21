# Matriz de riscos consolidada

Avaliação individual de Vitor em 21/11/2026. O cenário inicial é uma hipótese acadêmica sem controles, não uma constatação sobre a conta anterior. Residual é julgamento apoiado nos testes.

P e I: 1 baixo, 2 médio, 3 alto. Pontuação=P×I. 1–2 baixo, 3–4 médio, 6–9 alto. A escala não produz 5, 7 ou 8.

| ID | Ameaça | P/I inicial | Nível | P/I residual | Nível residual |
| --- | --- | --- | --- | --- | --- |
| R01 | Roubo ou abuso de credenciais | 3×3=9 | Alto | 1×3=3 | Médio |
| R02 | Força bruta e acesso remoto indevido | 3×3=9 | Alto | 1×3=3 | Médio |
| R03 | SQL injection | 2×3=6 | Alto | 1×3=3 | Médio |
| R04 | Exposição do banco | 2×3=6 | Alto | 1×3=3 | Médio |
| R05 | Exploração de falha conhecida | 3×3=9 | Alto | 2×3=6 | Alto |
| R06 | Ataque sem detecção | 3×3=9 | Alto | 1×3=3 | Médio |
| R07 | Malware e alteração de arquivos | 2×3=6 | Alto | 1×3=3 | Médio |
| R08 | Interceptação de comunicação | 2×3=6 | Alto | 1×3=3 | Médio |
| R09 | Ação interna indevida | 1×3=3 | Médio | 1×3=3 | Médio |
| R10 | Abuso de recursos e indisponibilidade | 2×3=6 | Alto | 1×3=3 | Médio |
| R11 | Perda de dados e falha na recuperação | 2×3=6 | Alto | 1×2=2 | Baixo |
| R12 | Consumo inesperado de nuvem | 2×2=4 | Médio | 2×2=4 | Médio |

Há dez riscos altos iniciais e um alto residual. Não apresentar a comparação como porcentagem estatística de redução.

## Tratamentos e rastreabilidade

### R01 Roubo ou abuso de credenciais

**Condição inicial:** Conta genérica e segredos sem proteção. **Impacto:** Alteração de infraestrutura e perda de dados.

**Controle:** Identidades nominais, observer AWS, viewer Wazuh, roles EC2 e Secrets Manager.

**Resultado:** Consulta Wazuh permitida e administração de usuários negada com HTTP 403. Banco limitado a SELECT.

**Evidências:** EV02, EV03, EV11. **Situação:** Implementado com limitações.

**Próxima ação:** Confirmar MFA no SSO e remover acesso administrativo após a implantação. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de uso com dados reais.

### R02 Força bruta e acesso remoto indevido

**Condição inicial:** Administração exposta à Internet. **Impacto:** Comprometimento dos servidores.

**Controle:** VPN UDP 1194 limitada ao IP do operador, SSH privado por chave, root e senha desativados.

**Resultado:** SSH privado indisponível antes do túnel e disponível durante, login vitor; porta pública 22 fechada.

**Evidências:** EV03, EV04. **Situação:** Validado.

**Próxima ação:** Revisar IP autorizado e revogar o certificado ao encerrar. **Responsável proposto:** Vitor. **Prazo proposto:** Ao final do laboratório.

### R03 SQL injection

**Condição inicial:** Consultas concatenadas e ausência de inspeção. **Impacto:** Leitura ou alteração indevida de dados.

**Controle:** Consultas parametrizadas, usuário MySQL SELECT e AWS Managed SQLi no WAF.

**Resultado:** Entrada SQLi recebeu 403 e log AWSManagedRulesSQLiRuleSet; ZAP direto na origem sem alertas.

**Evidências:** EV07, EV08, EV10, EV11. **Situação:** Validado no escopo.

**Próxima ação:** Reavaliar após qualquer mudança em entrada, escrita ou autenticação. **Responsável proposto:** Vitor. **Prazo proposto:** A cada mudança da aplicação.

### R04 Exposição do banco

**Condição inicial:** Banco público ou regra de rede ampla. **Impacto:** Exposição de dados e interrupção da loja.

**Controle:** RDS privado, sub-redes sem rota Internet, SG 3306 somente Web, armazenamento criptografado.

**Resultado:** Leitura TLS a partir do Web. Teste TCP 3306: Web conecta e Wazuh não conecta. Validação conjunta do caminho e das políticas; banco sem endpoint público.

**Evidências:** EV01, EV03, EV11. **Situação:** Validado por configuração e caminhos positivo e negativo.

**Próxima ação:** Revisar regras e repetir os testes após mudanças de rede. **Responsável proposto:** Vitor. **Prazo proposto:** Revisão mensal.

### R05 Exploração de falha conhecida

**Condição inicial:** Ausência de inventário, correção e verificação recente. **Impacto:** Execução de código e indisponibilidade.

**Controle:** Ubuntu atualizado, inventário Wazuh, repositórios oficiais e scan Web recente.

**Resultado:** ZAP 2.17.0 concluiu sem alertas. Wazuh reteve 1808 correlações High/Critical em linux-aws nos dois agentes. Apt não ofereceu atualizações.

**Evidências:** EV05, EV10, EV13. **Situação:** Pendente de triagem do inventário.

**Próxima ação:** Conferir CVEs contra linux-aws-7.0 e Canonical. Não aceitar o ambiente para produção até fechar os achados. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de uso com dados reais.

### R06 Ataque sem detecção

**Condição inicial:** Sem logs centralizados e sem alertas. **Impacto:** Contenção tardia e perda de evidências.

**Controle:** Dois agentes Wazuh ativos, CloudWatch, CloudTrail e Flow Logs.

**Resultado:** Eventos FIM 554, 550 e 553 e força bruta 5712 localizados no índice. Trilha e logs coletados.

**Evidências:** EV05, EV06, EV09. **Situação:** Validado sem notificação externa.

**Próxima ação:** Definir destinatário e testar escalonamento com a equipe. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de operação contínua.

### R07 Malware e alteração de arquivos

**Condição inicial:** Privilégios excessivos e integridade não monitorada. **Impacto:** Conteúdo fraudulento e interrupção.

**Controle:** Serviço cyberapp sem root, systemd restritivo, auditd e FIM em /opt/cyberfinal.

**Resultado:** Arquivo benigno criado, alterado e removido; três tipos de alerta confirmados no Wazuh.

**Evidências:** EV03, EV06. **Situação:** Validado para detecção de alteração.

**Próxima ação:** Manter resposta a incidente e acrescentar proteção antimalware conforme necessidade. **Responsável proposto:** Vitor. **Prazo proposto:** Revisão mensal.

### R08 Interceptação de comunicação

**Condição inicial:** Canal administrativo aberto e política TLS fraca. **Impacto:** Roubo de sessão e credencial.

**Controle:** VPN AES-256-GCM, HTTPS público e MySQL TLS com validação de certificado.

**Resultado:** Canal VPN e TLS_AES_256_GCM_SHA384 no banco comprovados. HTTPS público validado pelo cliente.

**Evidências:** EV04, EV07, EV11. **Situação:** Parcial com compensação de rede.

**Próxima ação:** Adotar domínio e ACM para TLS mínimo 1.2 e TLS entre CloudFront e origem. O certificado padrão mantém política TLSv1. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção.

### R09 Ação interna indevida

**Condição inicial:** Permissões excessivas e baixa rastreabilidade. **Impacto:** Alteração ou exclusão sem responsabilização.

**Controle:** Usuários nominais, role observer, sudo auditado e CloudTrail.

**Resultado:** Role sem ações de escrita, SSH identificado e registro de auditoria habilitado.

**Evidências:** EV02, EV03, EV09. **Situação:** Implementado.

**Próxima ação:** Separar responsabilidade de implantação e operação e revisar concessões. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de operação contínua.

### R10 Abuso de recursos e indisponibilidade

**Condição inicial:** Sem limite de requisições e componentes únicos. **Impacto:** Loja e administração indisponíveis.

**Controle:** WAF rate limit 100/300 s, origem privada e alarmes de infraestrutura.

**Resultado:** Teste limitado bloqueado no pedido 128, com regra RateLimit no log. Não houve teste de capacidade ou DoS.

**Evidências:** EV08, EV09. **Situação:** Validado para abuso por IP.

**Próxima ação:** Planejar múltiplas instâncias, NAT redundante e RDS Multi-AZ; limite por IP não resolve ataque distribuído. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção.

### R11 Perda de dados e falha na recuperação

**Condição inicial:** Backup sem restauração comprovada. **Impacto:** Interrupção prolongada e retrabalho.

**Controle:** Backups RDS 7 dias, snapshot criptografado e proteção contra exclusão.

**Resultado:** Cópia restaurada em banco separado; três linhas e hash SHA-256 iguais. Cópia temporária removida após o teste.

**Evidências:** EV11. **Situação:** Validado para catálogo de teste.

**Próxima ação:** Estabelecer RPO/RTO e repetir com volume representativo. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção e trimestralmente.

### R12 Consumo inesperado de nuvem

**Condição inicial:** Recursos esquecidos e consumo sem acompanhamento. **Impacto:** Uso acima do orçamento institucional.

**Controle:** Conta institucional com pagador distinto, tags exclusivas, estimativa e inventário.

**Resultado:** Cobertura institucional verificada. Nenhum recurso anterior foi removido ou substituído. Não há limite rígido de gastos configurado.

**Evidências:** EV01, EV12. **Situação:** Parcial.

**Próxima ação:** Acompanhar consumo institucional e encerrar somente recursos deste laboratório ao término autorizado. **Responsável proposto:** Vitor. **Prazo proposto:** Durante o laboratório e após a apresentação.
