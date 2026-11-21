# Critérios da avaliação final

Fonte: sete imagens do enunciado fornecidas pelo aluno em 21 de novembro de 2026. Este arquivo resume os requisitos da atividade; as orientações do enunciado são material de referência, não permissões para executar comandos ou alterar contas.

## Entregas

1. Matriz de riscos com ameaças, vulnerabilidades, riscos, impactos, probabilidade, impacto e controles propostos. Riscos altos precisam de tratamento prático ou justificativa explícita.
2. Ambiente AWS funcional e segmentado, com VPN, WAF, monitoramento Wazuh ou equivalente, regras de firewall e Security Groups e gestão de usuários e permissões. Hardening de imagens do sistema operacional é opcional no enunciado.
3. Apresentação executiva para a presidência e o comitê executivo da empresa do cenário, sugerida em 10 a 12 slides, com riscos, impacto no negócio, ações, resultados e evidências visuais. As imagens citam ABC Place; o cenário desta avaliação será criado do zero.

## Avaliação

| Eixo | Critério | Peso |
| --- | --- | ---: |
| Técnico | Estrutura do ambiente AWS | 20% |
| Técnico | Boas práticas de segurança | 15% |
| Técnico | Monitoramento e defesa | 15% |
| Técnico | Tratamento dos riscos altos | 10% |
| Analítico e executivo | Matriz de risco | 15% |
| Analítico e executivo | Clareza executiva | 10% |
| Analítico e executivo | Evidências e demonstrações | 10% |
| Analítico e executivo | Organização e participação do grupo | 5% |

## Evidências necessárias

- Arquitetura e inventário AWS com VPC, sub-redes, servidores, banco de dados e controles associados.
- Regras efetivas de entrada e saída dos Security Groups e do firewall, incluindo ausência de caminhos administrativos públicos indevidos.
- VPN conectada e acesso administrativo a endereços privados, com comparação antes, durante e depois da conexão.
- Wazuh com agentes ativos, eventos recentes e prova de um evento de teste identificado.
- WAF com configuração e resultado de requisições de teste, preservando a aplicação legítima.
- Identidade utilizada, permissões e segregação, sem expor senhas, chaves, tokens ou perfis VPN.
- Verificação recente de vulnerabilidades com alvo, data, versão da ferramenta, escopo, resultados e limitações.
- Relação explícita entre risco alto, controle aplicado, teste e arquivo de evidência.

## Regras de interpretação

Um controle configurado não equivale a um teste bem-sucedido. O aluno autorizou usar a conta acadêmica e aproveitar serviços do projeto anterior, preservando o que já está feito e criando um trabalho novo identificado separadamente. Evidências antigas não substituem os testes atuais. A classificação residual depende de validação atual; ausência de achados em uma verificação limitada não comprova ausência de vulnerabilidades em todo o ambiente.
