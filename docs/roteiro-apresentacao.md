# Roteiro de apresentação do Grupo 09

Integrantes: **Vitor, Artur Cruz e Daniel Juho**. Divisão proposta em três blocos de quatro slides, cerca de 10 minutos ao todo. Os blocos são uma proposta de fala, sem atribuir retrospectivamente quem executou cada configuração. Ensaiar as transições e usar as capturas se a sessão AWS estiver expirada.

| Slide | Apresentador | Mensagem e fala sugerida | Tempo |
| --- | --- | --- | --- |
| 1 | Artur Cruz | “Avaliamos a evolução da segurança da ABC Place, o mesmo projeto WordPress/WooCommerce dos roteiros.” Identificar o trio. | 35 s |
| 2 | Artur Cruz | Ligar IAM, análise de riscos, Wazuh e monitoramento/VPN às etapas anteriores. Explicar a nova VPC como ambiente de evolução separado. | 55 s |
| 3 | Artur Cruz | Traduzir insider, malware, informação comprometida, interceptação, DoS e injeção em impactos em venda, operação e confiança. | 45 s |
| 4 | Artur Cruz | Mostrar os 14 IDs e a escala original. Nove extremos e cinco altos no cenário inicial; seis altos e oito moderados na revisão. Não são probabilidades medidas. | 60 s |
| 5 | Vitor | Mostrar os controles mínimos e por que seis riscos continuam altos. Não dizer que a matriz ficou totalmente mitigada. | 55 s |
| 6 | Vitor | Percorrer WordPress, Web privado, RDS e borda. O banco atual é RDS; no roteiro anterior era EC2. Não afirmar que houve migração integral. | 60 s |
| 7 | Vitor | Explicar os testes antes/durante/depois da VPN e o login nominal. Acesso dos três integrantes ainda precisa de concessão própria. | 45 s |
| 8 | Vitor | Apontar os três eventos FIM na árvore WordPress e a regra SSH 5712 anterior. FIM detecta alteração; não comprova prevenção de ransomware. | 50 s |
| 9 | Daniel Juho | Relacionar bloqueios e logs WAF. Distinguir o rate limit Cloudflare do roteiro 4 e o AWS WAF da evolução. | 50 s |
| 10 | Daniel Juho | Mostrar scan WordPress separado do scan Python e os 54 informativos. A restauração testada é do catálogo técnico, não do WordPress completo. | 60 s |
| 11 | Daniel Juho | Explicar a distribuição qualitativa e seus limites. Não calcular porcentagem de risco eliminado. | 45 s |
| 12 | Daniel Juho | Concluir com próximos passos e responsáveis; manter uso acadêmico até fechar as pendências. | 40 s |

**Transição Artur → Vitor:** “Partimos desses 14 cenários. O Vitor vai mostrar como os controles aparecem na arquitetura e nos testes.”

**Transição Vitor → Daniel:** “Os controles de acesso e detecção estão demonstrados. O Daniel vai ligar a proteção Web, a varredura e os limites às decisões seguintes.”

## Demonstração curta e perguntas

Abrir o catálogo WordPress e buscar Caderno. Mostrar o FIM já registrado no Wazuh pela VPN e os logs WAF em consulta. Evitar repetir a sequência de taxa durante a fala. Não mostrar senhas, perfil VPN, chaves ou tokens.

**É continuação dos roteiros?** Sim, do caso ABC Place, da tecnologia WordPress/WooCommerce, dos requisitos e dos 14 riscos. A implementação final está numa VPC de evolução separada; o domínio e os recursos anteriores foram preservados.

**Por que mudou Apache/MariaDB/Cloudflare?** O novo ambiente demonstra uma alternativa de evolução em AWS com Nginx/PHP-FPM, RDS MySQL e AWS WAF. Não se afirma que a infraestrutura antiga foi convertida ou conectada à nova.

**Todos os riscos foram eliminados?** Não. Há seis altos com controles parciais e justificativa. O kernel é R03 nesta revisão, e não deve ser encerrado pelo resultado do ZAP.

**O SNS já foi testado?** O roteiro 4 registrou entrega de ALARM/OK no fluxo antigo. Isso não prova notificação externa configurada nos alarmes novos.

**O scan ficou sem alertas?** WordPress não teve High/Medium/Low no escopo público executado, mas gerou 54 registros informativos. Não houve teste autenticado do painel ou de checkout.

**O backup recupera toda a loja?** O teste realizado recuperou três linhas do catálogo técnico. Arquivos, uploads, plugins e dados de pedidos do WordPress exigem uma validação completa adicional.

Se alterarem as pontuações da matriz, atualizem também a tabela do slide 4, o gráfico do slide 11 e os totais do relatório. Os arquivos editáveis não se atualizam entre si automaticamente.
