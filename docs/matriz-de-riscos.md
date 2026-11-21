# Matriz de riscos inicial

Esta matriz foi construída do zero para a proposta do laboratório. As probabilidades e os impactos são estimativas acadêmicas do cenário sem os controles propostos. Não representam vulnerabilidades já observadas em uma conta AWS. As imagens da avaliação não incluem o relato completo do caso nem a tabela de ameaças citada no roteiro; esses materiais precisam ser confirmados antes da versão final.

## Método

Probabilidade: 1 baixa, 2 média, 3 alta. Impacto: 1 baixo, 2 médio, 3 alto. Pontuação = probabilidade × impacto. Classificação: 1–2 baixo, 3–4 médio, 6–9 alto. O produto desta escala não produz 5, 7 ou 8. O risco residual só será classificado depois de validar o controle e registrar a evidência.

| ID | Ameaça | Vulnerabilidade ou condição inicial hipotética | Impacto no negócio | P | I | Pontos | Nível |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| R01 | Roubo ou abuso de credencial | Conta genérica privilegiada e segredos sem proteção | Alteração da infraestrutura e perda de dados | 3 | 3 | 9 | Alto |
| R02 | Força bruta e acesso remoto indevido | Administração exposta diretamente à Internet | Comprometimento dos servidores | 3 | 3 | 9 | Alto |
| R03 | SQL injection | Entradas concatenadas em consultas e ausência de inspeção | Leitura ou alteração indevida do catálogo e dos dados | 2 | 3 | 6 | Alto |
| R04 | Exposição do banco | Banco público ou regra de rede ampla | Acesso externo a dados e interrupção da loja | 2 | 3 | 6 | Alto |
| R05 | Exploração de falha conhecida | Pacotes sem inventário, correções e verificação recente | Execução de código ou indisponibilidade | 3 | 3 | 9 | Alto |
| R06 | Ataque sem detecção | Ausência de logs centralizados, agentes e alertas | Contenção tardia e perda de evidências | 3 | 3 | 9 | Alto |
| R07 | Malware e alteração de arquivos | Privilégios excessivos e integridade sem acompanhamento | Conteúdo fraudulento e interrupção do serviço | 2 | 3 | 6 | Alto |
| R08 | Interceptação de comunicação | Canal administrativo aberto ou política TLS fraca | Roubo de sessão ou credencial | 2 | 3 | 6 | Alto |
| R09 | Ação interna indevida | Permissões além da função e baixa rastreabilidade | Alterações e exclusões sem responsabilização | 1 | 3 | 3 | Médio |
| R10 | Abuso de recursos e negação de serviço | Requisições sem limite e componentes únicos | Perda de acesso à loja e à operação | 2 | 3 | 6 | Alto |
| R11 | Perda de dados e falha de recuperação | Backups e restauração não comprovados | Interrupção prolongada e retrabalho | 2 | 3 | 6 | Alto |
| R12 | Consumo inesperado de nuvem | Recursos esquecidos e tráfego sem acompanhamento | Gasto acima do orçamento acadêmico | 2 | 2 | 4 | Médio |

## Tratamentos e comprovação

| ID | Controle preparado ou proposto | Teste necessário | Evidência prevista | Situação residual |
| --- | --- | --- | --- | --- |
| R01 | Identidade nominal, roles, Secrets Manager e exclusão de segredos do Git | Conferir permissões e ausência de senha/chave no código e capturas | EV02 | A validar |
| R02 | VPN /32, SSH apenas a partir da VPN e login nominal por chave | Comparar acesso privado antes, durante e após o túnel | EV03 e EV04 | A validar |
| R03 | Consulta parametrizada, banco com SELECT restrito e grupo SQLi no WAF | Testar o caminho MySQL real, entrada maliciosa e bloqueio correlacionado no WAF | EV07, EV08 e EV10 | A validar; testes locais não comprovam a borda AWS |
| R04 | RDS privado, sub-redes isoladas e 3306 somente do SG Web | Conferir configuração efetiva e tentativa de conexão fora da origem permitida | EV01 e EV03 | A validar |
| R05 | Ubuntu atual, atualizações, inventário Wazuh e scan recente | Atualizar, verificar vulnerabilidades e repetir a avaliação depois das correções | EV05 e EV10 | A validar |
| R06 | Wazuh, CloudWatch, CloudTrail e Flow Logs | Gerar evento benigno, localizar o alerta e conferir a data da ingestão | EV05, EV06 e EV09 | A validar; notificação externa pendente |
| R07 | Serviço sem root, restrição de escrita, auditd e FIM | Criar, alterar e remover arquivo de teste; localizar os três eventos | EV06 | A validar; FIM detecta e não impede todo malware |
| R08 | HTTPS externo, VPN, TLS com validação no RDS | Validar certificado e protocolos; revisar o trecho HTTP privado | EV04 e EV10 | Domínio com ACM e revisão do TLS ainda pendentes |
| R09 | Conta nominal, sudo auditado e CloudTrail | Registrar e localizar ação identificada do operador | EV02 e EV09 | A validar |
| R10 | WAF com rate limiting, origem privada e alarmes | Teste de baixa carga controlada, bloqueio e recuperação; registrar limite de capacidade | EV08 e EV09 | Componentes únicos exigem justificativa acadêmica |
| R11 | Backup RDS de 7 dias, criptografia, proteção contra exclusão e snapshot final | Restaurar cópia separada e comparar dados de teste | EV12 | Recuperação ainda não comprovada |
| R12 | Tags próprias, estimativa de custo e procedimento de encerramento | Conferir custos e inventariar recursos remanescentes após o laboratório | EV01 | Orçamento e forma de acompanhamento pendentes |

## Sete pontos para organizar o diagnóstico

Como proposta de organização: identidade privilegiada; acesso remoto; proteção Web; separação aplicação–banco; gestão de vulnerabilidades; monitoramento; recuperação. Esta lista não substitui os sete pontos de um caso do curso que ainda não tenha sido fornecido.

Os dez riscos altos acima têm uma resposta prevista. Nenhum deles está declarado como mitigado na AWS nesta versão. O fechamento exige configuração aplicada, teste, evidência atual e registro do risco residual ou de uma justificativa para a pendência.
