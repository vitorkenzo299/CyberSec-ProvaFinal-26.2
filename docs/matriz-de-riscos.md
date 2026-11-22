# Matriz de riscos da ABC Place

Grupo 09: **Vitor, Artur Cruz e Daniel Juho**. Continuidade dos 14 IDs da matriz do Roteiro 2.

A escala original foi preservada: P e I de 1 a 4; 1–2 baixo, 3–6 moderado, 7–9 alto, >9 extremo. No formato de três níveis da avaliação final, moderado corresponde a médio, e alto/extremo correspondem a alto. Os valores são julgamentos ordinais, sem frequência estatística atribuída.

O original contém nove extremos e cinco altos. A estimativa residual desta implantação contém seis altos e oito moderados. São cenários da ABC Place, não uma medição de falhas reais no ambiente antigo. Os residuais originais eram metas; foram reavaliados conforme as provas e limitações atuais.

| ID | Cenário | Inicial | Residual | Situação |
| --- | --- | --- | --- | --- |
| R01 | Identidades privilegiadas | 4×4=16 Extremo | 2×4=8 Alto | Parcial; alto justificado |
| R02 | Configuração insegura | 4×3=12 Extremo | 2×3=6 Moderado | Implementado com limites |
| R03 | Vulnerabilidades conhecidas | 4×4=16 Extremo | 2×4=8 Alto | Alto pendente de triagem |
| R04 | Acesso remoto indevido | 3×4=12 Extremo | 1×4=4 Moderado | Validado no ambiente novo |
| R05 | Tráfego Web malicioso | 4×3=12 Extremo | 2×3=6 Moderado | Implementado e testado em escopo |
| R06 | Injeção na aplicação | 3×4=12 Extremo | 2×4=8 Alto | Parcial; alto justificado |
| R07 | Malware e ransomware | 3×4=12 Extremo | 2×4=8 Alto | Parcial; alto justificado |
| R08 | Ataque sem detecção | 4×3=12 Extremo | 2×3=6 Moderado | Validado com integração externa pendente |
| R09 | Negação de serviço | 3×3=9 Alto | 2×3=6 Moderado | Parcial |
| R10 | Exposição de dados | 3×4=12 Extremo | 2×4=8 Alto | Parcial; alto justificado |
| R11 | Falha de recuperação | 2×4=8 Alto | 1×4=4 Moderado | Teste parcial e limites explícitos |
| R12 | Movimento lateral ao banco | 2×4=8 Alto | 1×4=4 Moderado | Validado no ambiente novo |
| R13 | Ameaça interna | 3×3=9 Alto | 2×3=6 Moderado | Parcial |
| R14 | Interceptação de tráfego | 2×4=8 Alto | 2×4=8 Alto | Parcial; alto justificado |

## R01 Identidades privilegiadas

**Condição do caso:** Uso compartilhado de root/administrator, sem responsabilização individual e MFA comprovada

**Impacto no negócio:** Tomada completa dos servidores, alteração da loja, exclusão de dados e ocultação de rastros

**Controle atual:** SSO nominal, observer AWS, roles EC2, SSH vitor e viewer Wazuh. WordPress usa usuário nominal vitor para manutenção.

**Resultado e limite:** Wazuh negou administração de usuários (403); IAM de consulta sem ações de alteração. MFA e concessões individuais para todos os integrantes ainda não comprovadas.

**Evidências:** EV02, EV03, EV15. **Situação:** Parcial; alto justificado.

**Próxima ação:** Confirmar MFA e conceder acessos próprios a cada operador sem compartilhar a sessão de Vitor. **Responsável proposto:** Artur Cruz. **Prazo proposto:** Antes de operação contínua.

## R02 Configuração insegura

**Condição do caso:** Configurações padrão e ausência de baseline de hardening documentada

**Impacto no negócio:** Execução não autorizada, escalada de privilégio, movimento lateral e indisponibilidade

**Controle atual:** SSH por chave sem root ou senha; UFW, auditd, PHP sem edição de arquivos e árvore WordPress protegida.

**Resultado e limite:** Serviços e parâmetros SSH verificados. WordPress usa PHP-FPM; Nginx nega configuração, XML-RPC e administração pela Internet. Não é certificação CIS completa.

**Evidências:** EV03, EV15. **Situação:** Implementado com limites.

**Próxima ação:** Revisar baseline de Ubuntu, Nginx, PHP e WordPress após atualizações. **Responsável proposto:** Daniel Juho. **Prazo proposto:** Revisão mensal.

## R03 Vulnerabilidades conhecidas

**Condição do caso:** Não há inventário, rotina de correção, varredura ou SLA de vulnerabilidades

**Impacto no negócio:** Comprometimento remoto da loja, instalação de malware e acesso aos dados de clientes

**Controle atual:** Inventário Wazuh, atualização pelo repositório oficial e versões WordPress/WooCommerce registradas.

**Resultado e limite:** As correlações High/Critical do kernel continuam em triagem. Um exemplo Canonical sugere correlação imprecisa, sem autorizar descartar os demais. Scan Web é avaliação separada.

**Evidências:** EV05, EV13, EV16. **Situação:** Alto pendente de triagem.

**Próxima ação:** Tratar CVEs relevantes contra a fonte correta e executar testes autenticados dos plugins antes de produção. **Responsável proposto:** Daniel Juho. **Prazo proposto:** Antes de dados reais.

## R04 Acesso remoto indevido

**Condição do caso:** Acesso administrativo sem VPN ou canal privado comprovado

**Impacto no negócio:** Acesso externo ao servidor, alteração de configurações e implantação de backdoor

**Controle atual:** VPN UDP 1194 por origem /32, SSH privado por chave e usuário nominal.

**Resultado e limite:** Web e Wazuh inacessíveis antes e após o túnel, acessíveis durante; porta pública 22 fechada. Evidência nova não altera o SSH público preexistente nos servidores antigos.

**Evidências:** EV03, EV04. **Situação:** Validado no ambiente novo.

**Próxima ação:** Manter certificados individuais e planejar restrição do SSH legado em mudança própria. **Responsável proposto:** Vitor. **Prazo proposto:** Ao mudar operadores ou origem.

## R05 Tráfego Web malicioso

**Condição do caso:** Política de firewall, WAF e detecção de conexões maliciosas não comprovada

**Impacto no negócio:** Bots, exploração automatizada, injeção e abuso de recursos chegam diretamente à loja

**Controle atual:** AWS WAF com Common, SQLi, KnownBadInputs e taxa; CloudFront com origem privada.

**Resultado e limite:** Probe e SQLi bloqueados por regras confirmadas nos logs. WordPress foi publicado atrás da mesma distribuição. A Cloudflare do roteiro 4 continua no domínio legado.

**Evidências:** EV07, EV08, EV15. **Situação:** Implementado e testado em escopo.

**Próxima ação:** Revisar falsos positivos e exceções; manter painel administrativo fora do acesso público. **Responsável proposto:** Vitor. **Prazo proposto:** A cada alteração.

## R06 Injeção na aplicação

**Condição do caso:** Validação de entradas, testes de segurança e práticas de desenvolvimento seguro não comprovados

**Impacto no negócio:** Leitura, alteração ou exclusão de clientes, pedidos e configurações da aplicação

**Controle atual:** WAF SQLi, WordPress/WooCommerce oficiais, validação de entrada e banco limitado ao schema próprio.

**Resultado e limite:** O teste de assinatura confirma bloqueio na borda. O catálogo Python foi avaliado antes; a varredura WordPress tem resultado separado e não comprova checkout, plugins autenticados ou ausência de toda injeção.

**Evidências:** EV08, EV10, EV16. **Situação:** Parcial; alto justificado.

**Próxima ação:** Executar revisão de plugins e testes autenticados antes de habilitar clientes, pedidos e checkout. **Responsável proposto:** Artur Cruz. **Prazo proposto:** Antes de operação comercial.

## R07 Malware e ransomware

**Condição do caso:** Hardening, correções, segmentação de acesso e recuperação ainda insuficientes ou não comprovados

**Impacto no negócio:** Criptografia de sistemas e dados, interrupção de vendas e possível extorsão por vazamento

**Controle atual:** FIM, auditd, restrição de escrita no WordPress, privilégios limitados e snapshot criptografado.

**Resultado e limite:** FIM detectou criação, modificação e exclusão de arquivo benigno. Isso não demonstra prevenção de ransomware ou cobertura EDR. Restauração do catálogo técnico foi testada.

**Evidências:** EV06, EV11, EV15. **Situação:** Parcial; alto justificado.

**Próxima ação:** Definir EDR e testar resposta e restauração completa de banco, arquivos e uploads. **Responsável proposto:** Daniel Juho. **Prazo proposto:** Antes de dados reais.

## R08 Ataque sem detecção

**Condição do caso:** Logs não centralizados e ausência de alertas e rotina de análise

**Impacto no negócio:** Maior permanência do invasor, perda de evidências e contenção tardia

**Controle atual:** Wazuh com dois agentes, CloudWatch, CloudTrail e Flow Logs. FIM da árvore WordPress incluído.

**Resultado e limite:** FIM e SSH 5712 confirmados nesta avaliação. Roteiro 4 registrou SNS recebido; não se presume que aquele tópico esteja ligado aos alarmes novos.

**Evidências:** EV05, EV06, EV09, EV14, EV15. **Situação:** Validado com integração externa pendente.

**Próxima ação:** Integrar os alarmes novos ao fluxo de notificação autorizado e repetir entrega e escalonamento. **Responsável proposto:** Daniel Juho. **Prazo proposto:** Antes de operação contínua.

## R09 Negação de serviço

**Condição do caso:** Capacidade, rate limiting, proteção DDoS e procedimento de resposta não comprovados

**Impacto no negócio:** Loja e checkout indisponíveis durante picos de ataque

**Controle atual:** CloudFront e WAF rate limit 100 por 300 s; métricas e alarmes de infraestrutura.

**Resultado e limite:** Teste limitado bloqueado no pedido 128. Roteiro 4 usou Cloudflare no /wp-admin com parâmetros próprios. Não houve teste de capacidade nem prova contra DDoS distribuído.

**Evidências:** EV08, EV09, EV14. **Situação:** Parcial.

**Próxima ação:** Planejar redundância Web/NAT/RDS e testar capacidade com limite e autorização próprios. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção.

## R10 Exposição de dados

**Condição do caso:** Menor privilégio, criptografia, trilhas de acesso e monitoramento do banco não comprovados

**Impacto no negócio:** Fraude, exposição de dados pessoais, comunicação à ANPD e titulares, sanções e dano reputacional

**Controle atual:** RDS privado e criptografado, TLS, schema WordPress separado e usuário de execução sem DDL.

**Resultado e limite:** Catálogo técnico usa SELECT; WordPress precisa de SELECT/INSERT/UPDATE/DELETE somente em abcplace_wp. Não há clientes nem dados pessoais nesta implantação.

**Evidências:** EV03, EV11, EV15. **Situação:** Parcial; alto justificado.

**Próxima ação:** Validar trilhas, retenção, tratamento de dados e plano de incidente antes de importar clientes ou pedidos. **Responsável proposto:** Artur Cruz. **Prazo proposto:** Antes de dados pessoais.

## R11 Falha de recuperação

**Condição do caso:** Backups isolados, testes de restauração, RTO e RPO não comprovados

**Impacto no negócio:** Perda permanente de dados ou interrupção prolongada da operação

**Controle atual:** RDS com sete dias de backup, snapshot criptografado e teste de cópia separada.

**Resultado e limite:** Três linhas do catálogo técnico foram restauradas com hash igual. O teste antecede o WordPress e não prova recuperação de uploads, plugins ou pedidos.

**Evidências:** EV11, EV15. **Situação:** Teste parcial e limites explícitos.

**Próxima ação:** Testar restauração completa WordPress e definir RPO/RTO representativos antes de produção. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção.

## R12 Movimento lateral ao banco

**Condição do caso:** O caso previa co-localização; o projeto separou as instâncias, mas as regras de rede e hardening precisam de validação contínua

**Impacto no negócio:** Comprometimento da aplicação alcança diretamente dados críticos

**Controle atual:** Web e RDS em sub-redes separadas; 3306 apenas do SG Web e sem endpoint público.

**Resultado e limite:** Teste positivo Web→RDS e negativo Wazuh→RDS. Valida o caminho e as políticas em conjunto. Banco RDS gerenciado substitui EC2/MariaDB nesta evolução.

**Evidências:** EV01, EV03, EV11. **Situação:** Validado no ambiente novo.

**Próxima ação:** Revisar regras e repetir os testes após mudança de rede. **Responsável proposto:** Vitor. **Prazo proposto:** Revisão mensal.

## R13 Ameaça interna

**Condição do caso:** Contas compartilhadas, excesso de privilégio e baixa rastreabilidade

**Impacto no negócio:** Exclusão de dados, fraude, alteração de pedidos ou cópia de informações sensíveis

**Controle atual:** Acesso nominal, role de leitura, sudo auditado, trilhas e funções de serviço separadas.

**Resultado e limite:** A execução técnica registrada usa Vitor; a divisão de fala é do trio. Nomes na capa não comprovam segregação de funções ou criação de acessos para os colegas.

**Evidências:** EV02, EV03, EV09. **Situação:** Parcial.

**Próxima ação:** Formalizar permissões e revisão de acessos para cada pessoa e responsabilidades de resposta. **Responsável proposto:** Artur Cruz. **Prazo proposto:** Antes de operação contínua.

## R14 Interceptação de tráfego

**Condição do caso:** HTTPS está em uso, mas VPN administrativa, política TLS e gestão de certificados não foram validadas

**Impacto no negócio:** Roubo de sessão, credenciais ou dados trafegados

**Controle atual:** VPN AES-256-GCM, HTTPS na borda e TLS no banco com CA e verificação do servidor.

**Resultado e limite:** Persistem a política TLSv1 do domínio CloudFront padrão e HTTP privado entre CloudFront e Nginx. Não se declara TLS ponta a ponta.

**Evidências:** EV04, EV07, EV11, EV15. **Situação:** Parcial; alto justificado.

**Próxima ação:** Usar domínio e ACM para política mínima TLS 1.2 e habilitar TLS na origem privada. **Responsável proposto:** Vitor. **Prazo proposto:** Antes de produção.
