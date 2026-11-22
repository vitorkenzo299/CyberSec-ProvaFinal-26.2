# Status da avaliação final ABC Place

Grupo 09: Vitor, Artur Cruz e Daniel Juho. Revisão em 21/11/2026 no horário de Brasília; registros após 21h aparecem como 22/11 em UTC.

| Item | Situação |
| --- | --- |
| Continuidade | Roteiros 1–4 localizados e mapeados; fontes e baseline preservadas |
| Matriz | 14 IDs originais; escala 4×4 e correspondência em três níveis; seis altos residuais justificados |
| Aplicação | WordPress/WooCommerce e três produtos sintéticos na infraestrutura nova |
| Banco | Schema próprio, privilégios DML limitados e TLS com testes negativos aprovados |
| VPN/WAF/Wazuh | Provas anteriores da final preservadas; novos testes HTTP e FIM WordPress adicionados |
| Scan WordPress | ZAP 2.17.0, 100%, 1.228 mensagens/16 URLs, zero High/Medium/Low e 54 informativos |
| Recuperação | Restauração do catálogo técnico comprovada; recuperação integral WordPress permanece pendente |
| Legado | Sem migração, troca de DNS ou alteração dos recursos anteriores |
| Apresentação | 12 slides com autoria do trio e quatro slides por integrante |

R01, R03, R06, R07, R10 e R14 permanecem altos. Há controles mínimos aplicados e justificativa para os limites. A triagem do kernel é R03 conforme a matriz do Roteiro 2. Produção exige concluir as pendências, testes autenticados, TLS de origem, MFA, notificação externa, recuperação completa e capacidade.
