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


## Conferência operacional adicional

Em 21/11/2026, entre 22h21 e 22h25 (Brasília), foram repetidas as consultas de saúde. Os registros estão em `evidencias/revisao-final/`.

| Verificação | Resultado atual |
| --- | --- |
| Cloudflare no domínio legado | abcplace.blog.br HTTP 200; rate limit bloqueou a sétima requisição com 429 e voltou a 302 após a espera |
| WordPress novo | HTTP 200, três produtos; busca Caderno retorna um produto |
| AWS | Três EC2 com verificações OK; RDS disponível, privado e criptografado; CloudFront Deployed e WAF associado |
| Wazuh | Serviços ativos, dois agentes externos ativos, três eventos FIM acessíveis como vitor; administração de usuários negada com 403 |
| VPN | SSH privado indisponível antes, disponível durante e indisponível depois; painel privado HTTP 200 durante a conexão |
| Logs | Eventos recentes de sistema, Flow Logs e WAF; CloudTrail gravando |
| Arquivos | Os cinco arquivos Office/PDF conferem com os hashes da revisão visual registrada |

O ambiente está operacional nos testes acima, com pendências. Cloudflare protege o domínio legado; o novo ambiente usa CloudFront/AWS WAF. Os alarmes novos estão sem ação externa, enquanto o tópico SNS antigo tem assinatura confirmada. Permanecem os seis riscos residuais altos e as limitações já justificadas no relatório. Não se declara integração total, migração concluída ou prontidão de produção.
