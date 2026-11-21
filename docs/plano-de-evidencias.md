# Plano de evidências

Cada evidência deve conter data, alvo, ação, resultado observado e risco relacionado. Capturas de tela precisam mostrar o controle e seu contexto, mantendo credenciais fora da imagem.

| ID | Conteúdo | Critério principal | Teste esperado |
| --- | --- | --- | --- |
| EV01 | Inventário AWS e arquitetura | Estrutura | Identificar recursos existentes e fluxos reais |
| EV02 | IAM e identidade de operação | Boas práticas | Identidade nominal e permissões adequadas |
| EV03 | Security Groups e firewall | Boas práticas | Administração pelo caminho autorizado e banco restrito |
| EV04 | VPN ativa | Estrutura e defesa | Acesso privado autenticado durante a conexão |
| EV05 | Wazuh e agentes | Monitoramento | Agentes ativos com horário recente |
| EV06 | Wazuh e evento controlado | Monitoramento | Evento produzido e alerta correlacionado |
| EV07 | WAF e regras | Defesa | Configuração efetiva e origem protegida |
| EV08 | WAF e bloqueio | Defesa | Requisição de teste bloqueada; acesso legítimo preservado |
| EV09 | Logs, métricas e alertas | Monitoramento | Registro recente e caminho de alerta observado |
| EV10 | Verificação de vulnerabilidades | Riscos altos | Relatório recente com escopo e limitações |
| EV11 | Matriz e riscos residuais | Análise | Cada risco alto ligado a controle, teste e resultado |
| EV12 | Backup e recuperação, se existentes | Continuidade | Evidência do backup e teste de restauração, quando executado |

## Organização

- `evidencias/atuais`: registros desta avaliação, com a data efetiva da coleta.
- `docs`: análise, arquitetura e rastreabilidade.
- `entrega`: relatório, matriz e apresentação para entrega.
- `.local`: dados de trabalho privados, ignorados pelo Git.

Os nomes dos arquivos devem identificar data e controle. O manifesto deve registrar SHA-256 dos arquivos incluídos, permitindo verificar a integridade. Chaves SSH, credenciais AWS, cookies, perfis VPN e senhas ficam fora do repositório. Evidências de outros projetos não podem ser apresentadas como resultados atuais desta avaliação.
