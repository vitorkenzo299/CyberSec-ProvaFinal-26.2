# Matriz de riscos da ABC Place

Grupo 09: Vitor, Artur Cruz e Daniel Juho. Revisão de 22/11/2026. Os 14 IDs, valores iniciais e metas históricas do Roteiro 2 foram preservados.

Escala original: P/I de 1 a 4; 1–2 baixo, 3–6 moderado, 7–9 alto, >9 extremo. Na leitura de três níveis: moderado=médio; alto/extremo=alto. São julgamentos ordinais, sem frequência estatística medida.

A revisão anterior tinha seis altos. MFA do operador e TLS foram comprovados; R14 passa a 1×4=4. R01 permanece alto porque a função AdministratorAccess foi usada nas mudanças AWS e o menor privilégio não está comprovado. Permanecem cinco altos e nove moderados. A triagem R03 recebeu controles compensatórios, mantendo o residual alto.

| ID | Cenário | Inicial | Residual | Situação |
| --- | --- | --- | --- | --- |
| R01 | Identidades privilegiadas | 16 Extremo | 8 Alto | Parcial; alto justificado |
| R02 | Configuração insegura | 12 Extremo | 6 Moderado | Implementado com limites |
| R03 | Vulnerabilidades conhecidas | 16 Extremo | 8 Alto | Tratamento parcial; alto justificado |
| R04 | Acesso remoto indevido | 12 Extremo | 4 Moderado | Validado no ambiente novo |
| R05 | Tráfego Web malicioso | 12 Extremo | 6 Moderado | Implementado e retestado |
| R06 | Injeção na aplicação | 12 Extremo | 8 Alto | Parcial; alto justificado |
| R07 | Malware e ransomware | 12 Extremo | 8 Alto | Parcial; alto justificado |
| R08 | Ataque sem detecção | 12 Extremo | 6 Moderado | Implementado e retestado |
| R09 | Negação de serviço | 9 Alto | 6 Moderado | Parcial |
| R10 | Exposição de dados | 12 Extremo | 8 Alto | Parcial; alto justificado |
| R11 | Falha de recuperação | 8 Alto | 4 Moderado | Recuperação acadêmica comprovada |
| R12 | Movimento lateral ao banco | 8 Alto | 4 Moderado | Validado no ambiente novo |
| R13 | Ameaça interna | 9 Alto | 6 Moderado | Parcial |
| R14 | Interceptação de tráfego | 8 Alto | 4 Moderado | Implementado e retestado |

## R01 Identidades privilegiadas

Condição original: Uso compartilhado de root/administrator, sem responsabilização individual e MFA comprovada

Impacto no negócio: Tomada completa dos servidores, alteração da loja, exclusão de dados e ocultação de rastros

Controle: Sessão nominal do AWS IAM Identity Center; dispositivo MFA de Vitor cadastrado; segundo fator Cloudflare por e-mail; SSH nominal e acesso do Wazuh por visualizador.

Resultado e limite: O dispositivo MFA de Vitor foi observado no portal institucional. A sessão usada para alterações AWS era AWSReservedSSO_AdministratorAccess; existe função de observação separada, mas menor privilégio não foi comprovado para as mudanças. Não audita MFA de root, política global do Insper ou identidades dos demais.

Evidências: EV02, EV19, EV23.

Próxima ação: Adotar função temporária de implantação com permissões mínimas revisadas; confirmar a política MFA da organização e acessos próprios dos demais integrantes. Acompanhamento proposto: Artur Cruz. Prazo proposto: Antes de operação contínua.

## R02 Configuração insegura

Condição original: Configurações padrão e ausência de baseline de hardening documentada

Impacto no negócio: Execução não autorizada, escalada de privilégio, movimento lateral e indisponibilidade

Controle: SSH por chave sem root ou senha; UFW, auditd, PHP sem edição de arquivos e árvore WordPress protegida.

Resultado e limite: Serviços e parâmetros SSH verificados. WordPress usa PHP-FPM; Nginx nega configuração, XML-RPC e administração pela Internet. Não é certificação CIS completa.

Evidências: EV03, EV15.

Próxima ação: Revisar baseline de Ubuntu, Nginx, PHP e WordPress após atualizações. Acompanhamento proposto: Daniel Juho. Prazo proposto: Revisão mensal.

## R03 Vulnerabilidades conhecidas

Condição original: Não há inventário, rotina de correção, varredura ou SLA de vulnerabilidades

Impacto no negócio: Comprometimento remoto da loja, instalação de malware e acesso aos dados de clientes

Controle: Atualizações oficiais em dia no canal instalado; Wazuh e OpenSCAP com OVAL Canonical; carga automática de 23 módulos sem uso bloqueada e io_uring desativada.

Resultado e limite: Os 1.019 CVEs distintos do snapshot Wazuh foram avaliados nos três hosts: 802 definições falsas e 217 verdadeiras, incluindo 37 High e 1 Critical por host na classificação Canonical. Não houve erro/unknown. As medidas compensatórias não são patches e o risco continua alto.

Evidências: EV05, EV13, EV21.

Próxima ação: Acompanhar correções do fornecedor para o kernel instalado, aplicar atualizações revisadas e repetir o inventário e a avaliação. Manter R03 alto até concluir a remediação dos casos aplicáveis. Acompanhamento proposto: Daniel Juho. Prazo proposto: Antes de dados reais.

## R04 Acesso remoto indevido

Condição original: Acesso administrativo sem VPN ou canal privado comprovado

Impacto no negócio: Acesso externo ao servidor, alteração de configurações e implantação de backdoor

Controle: VPN UDP 1194 por origem /32, SSH privado por chave e usuário nominal.

Resultado e limite: Web e Wazuh inacessíveis antes e após o túnel, acessíveis durante; porta pública 22 fechada. Evidência nova não altera o SSH público preexistente nos servidores antigos.

Evidências: EV03, EV04.

Próxima ação: Manter certificados individuais e planejar restrição do SSH legado em mudança própria. Acompanhamento proposto: Vitor. Prazo proposto: Ao mudar operadores ou origem.

## R05 Tráfego Web malicioso

Condição original: Política de firewall, WAF e detecção de conexões maliciosas não comprovada

Impacto no negócio: Bots, exploração automatizada, injeção e abuso de recursos chegam diretamente à loja

Controle: Cloudflare e AWS WAF no mesmo caminho da loja final; cinco regras AWS, listas oficiais de origem, assinaturas SQLi e taxa por CF-Connecting-IP.

Resultado e limite: Catálogo/busca 200, probe e SQLi 403 correlacionados aos logs. Acesso direto ao CloudFront com IP forjado foi negado. Cloudflare limitou /wp-admin com 429 e recuperou para o 403 administrativo esperado.

Evidências: EV07, EV08, EV17.

Próxima ação: Revisar listas oficiais Cloudflare e falsos positivos após mudanças; manter administração pública bloqueada. Acompanhamento proposto: Vitor. Prazo proposto: A cada alteração.

## R06 Injeção na aplicação

Condição original: Validação de entradas, testes de segurança e práticas de desenvolvimento seguro não comprovados

Impacto no negócio: Leitura, alteração ou exclusão de clientes, pedidos e configurações da aplicação

Controle: WAF SQLi, WordPress/WooCommerce oficiais, validação de entrada e banco limitado ao schema próprio.

Resultado e limite: O teste de assinatura confirma bloqueio na borda. O catálogo Python foi avaliado antes; a varredura WordPress tem resultado separado e não comprova checkout, plugins autenticados ou ausência de toda injeção.

Evidências: EV08, EV10, EV16.

Próxima ação: Executar revisão de plugins e testes autenticados antes de habilitar clientes, pedidos e checkout. Acompanhamento proposto: Artur Cruz. Prazo proposto: Antes de operação comercial.

## R07 Malware e ransomware

Condição original: Hardening, correções, segmentação de acesso e recuperação ainda insuficientes ou não comprovados

Impacto no negócio: Criptografia de sistemas e dados, interrupção de vendas e possível extorsão por vazamento

Controle: FIM, auditd, escrita restrita no WordPress, privilégios limitados, backups RDS e cópia WordPress AES-256-GCM em S3 privado/versionado.

Resultado e limite: Restauração isolada conferiu 52 tabelas, 8.808 arquivos e catálogo/busca 200. A origem permaneceu íntegra e adulteração do arquivo criptografado foi rejeitada. Isso não comprova prevenção de ransomware ou uma cópia imutável independente.

Evidências: EV06, EV15, EV20.

Próxima ação: Definir prevenção/resposta a ransomware e retenção independente. Repetir backup sob demanda antes da apresentação; operação comercial exige política contínua aprovada. Acompanhamento proposto: Daniel Juho. Prazo proposto: Antes de dados reais.

## R08 Ataque sem detecção

Condição original: Logs não centralizados e ausência de alertas e rotina de análise

Impacto no negócio: Maior permanência do invasor, perda de evidências e contenção tardia

Controle: Wazuh com agentes Web/VPN; CloudWatch, CloudTrail e Flow Logs; oito alarmes ligados ao SNS confirmado do Roteiro 4.

Resultado e limite: Download real acionou rede e recuperação, com duas publicações bem-sucedidas e recebimento ALARM/OK confirmado pelo usuário. O teste WAF gerou outro ciclo registrado; todos os oito alarmes voltaram a OK e permanecem habilitados.

Evidências: EV05, EV09, EV18.

Próxima ação: Revisar destinatários e resposta operacional; avaliar escalonamento e exercícios de incidente antes de produção. Acompanhamento proposto: Daniel Juho. Prazo proposto: Antes de operação contínua.

## R09 Negação de serviço

Condição original: Capacidade, rate limiting, proteção DDoS e procedimento de resposta não comprovados

Impacto no negócio: Loja e checkout indisponíveis durante picos de ataque

Controle: Cloudflare 5 requisições/10 s em /wp-admin; AWS WAF 100/300 s por visitante, origem privada e oito alarmes de infraestrutura.

Resultado e limite: Limitação Cloudflare e AWS WAF retestadas. A regra AWS usa IP encaminhado apenas de redes Cloudflare confiáveis. Testes limitados não medem capacidade ou resistência a DDoS distribuído.

Evidências: EV08, EV17, EV18.

Próxima ação: Planejar redundância Web/NAT/RDS e testar capacidade com limite e autorização próprios. Acompanhamento proposto: Vitor. Prazo proposto: Antes de produção.

## R10 Exposição de dados

Condição original: Menor privilégio, criptografia, trilhas de acesso e monitoramento do banco não comprovados

Impacto no negócio: Fraude, exposição de dados pessoais, comunicação à ANPD e titulares, sanções e dano reputacional

Controle: RDS privado e criptografado, TLS, schema WordPress separado e usuário de execução sem DDL.

Resultado e limite: Catálogo técnico usa SELECT; WordPress precisa de SELECT/INSERT/UPDATE/DELETE somente em abcplace_wp. Não há clientes nem dados pessoais nesta implantação.

Evidências: EV03, EV11, EV15.

Próxima ação: Validar trilhas, retenção, tratamento de dados e plano de incidente antes de importar clientes ou pedidos. Acompanhamento proposto: Artur Cruz. Prazo proposto: Antes de dados pessoais.

## R11 Falha de recuperação

Condição original: Backups isolados, testes de restauração, RTO e RPO não comprovados

Impacto no negócio: Perda permanente de dados ou interrupção prolongada da operação

Controle: RDS privado/criptografado com sete dias de backup; WordPress completo criptografado e versionado no bucket privado já existente.

Resultado e limite: Após configurar o domínio final, 52 tabelas e 8.808 arquivos coincidiram na cópia isolada. Catálogo e busca funcionaram; schema, usuário e listener temporários foram removidos. Tempo observado de 52,4 s não é um SLA de recuperação de desastre.

Evidências: EV11, EV20.

Próxima ação: Manter cópia sob demanda e chave de recuperação separada. Produção requer RPO/RTO aprovados, recorrência e testes de desastre completos. Acompanhamento proposto: Vitor. Prazo proposto: Antes de produção.

## R12 Movimento lateral ao banco

Condição original: O caso previa co-localização; o projeto separou as instâncias, mas as regras de rede e hardening precisam de validação contínua

Impacto no negócio: Comprometimento da aplicação alcança diretamente dados críticos

Controle: Web e RDS em sub-redes separadas; 3306 apenas do SG Web e sem endpoint público.

Resultado e limite: Teste positivo Web→RDS e negativo Wazuh→RDS. Valida o caminho e as políticas em conjunto. Banco RDS gerenciado substitui EC2/MariaDB nesta evolução.

Evidências: EV01, EV03, EV11.

Próxima ação: Revisar regras e repetir os testes após mudança de rede. Acompanhamento proposto: Vitor. Prazo proposto: Revisão mensal.

## R13 Ameaça interna

Condição original: Contas compartilhadas, excesso de privilégio e baixa rastreabilidade

Impacto no negócio: Exclusão de dados, fraude, alteração de pedidos ou cópia de informações sensíveis

Controle: Acesso nominal, role de leitura, sudo auditado, trilhas e funções de serviço separadas.

Resultado e limite: A execução técnica registrada usa Vitor; a divisão de fala é do trio. Nomes na capa não comprovam segregação de funções ou criação de acessos para os colegas.

Evidências: EV02, EV03, EV09.

Próxima ação: Formalizar permissões e revisão de acessos para cada pessoa e responsabilidades de resposta. Acompanhamento proposto: Artur Cruz. Prazo proposto: Antes de operação contínua.

## R14 Interceptação de tráfego

Condição original: HTTPS está em uso, mas VPN administrativa, política TLS e gestão de certificados não foram validadas

Impacto no negócio: Roubo de sessão, credenciais ou dados trafegados

Controle: Cloudflare TLS mínimo 1.2; Full strict para final.abcplace.blog.br; CloudFront TLSv1.2_2021; origem privada HTTPS verificada; TLS no banco e VPN.

Resultado e limite: TLS 1.0/1.1 recusados e 1.2/1.3 aceitos na borda. Origem usa certificado público Let’s Encrypt e renovação automática testada em dry-run, sem trocar o certificado de produção. O painel Wazuh continua com PKI privada da instalação dentro da VPN.

Evidências: EV04, EV11, EV17.

Próxima ação: Monitorar validade e renovação dos certificados; distribuir a CA privada Wazuh por canal confiável aos operadores, mantendo validação da identidade do servidor. Acompanhamento proposto: Vitor. Prazo proposto: Antes de produção.
