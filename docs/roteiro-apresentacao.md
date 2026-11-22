# Roteiro de apresentação do Grupo 09

**Integrantes:** Vitor, Artur Cruz e Daniel Juho. Divisão proposta em três blocos de quatro slides, cerca de dez minutos. A ordem coincide com as notas do arquivo editável.

| Slides | Apresentador | Mensagem principal |
| --- | --- | --- |
| 1–4 | Artur Cruz | ABC Place, continuidade dos roteiros, ameaças e os 14 IDs originais. A estimativa residual atual é cinco altos e nove moderados. |
| 5–8 | Vitor | Cinco riscos altos e seus limites, arquitetura, VPN, identidades e eventos FIM WordPress. |
| 9–12 | Daniel Juho | Borda Cloudflare/AWS WAF, scan e recuperação WordPress, resumo residual e próximos passos. |

## Falas e duração

1. **Artur:** “Esta avaliação continua o mesmo caso ABC Place e integra os roteiros 1 a 4. A loja final é uma demonstração com três produtos sintéticos, sem clientes ou pagamentos.” (35 s)
2. **Artur:** Relacionar IAM, matriz de riscos, Wazuh e CloudWatch/Cloudflare/VPN aos roteiros anteriores. Mencionar que apex, `www`, monitoramento e servidores legados foram preservados. Os oito alarmes estão ligados ao SNS existente; o ciclo de rede foi confirmado. (55 s)
3. **Artur:** Traduzir insider, malware, comprometimento de informação, interceptação, DoS e injeção de código em impactos de venda, operação e confiança. São cenários, não incidentes observados. (45 s)
4. **Artur:** Mostrar os 14 cenários. O original tinha nove extremos e cinco altos; a revisão atual tem cinco altos e nove moderados. A escala é qualitativa, não probabilidade medida. (60 s)
5. **Vitor:** Justificar R01, R03, R06, R07 e R10. R01 inclui o uso de `AdministratorAccess`; o menor privilégio precisa ser revisto. R03 ainda tem achados de kernel sem patch demonstrado. (55 s)
6. **Vitor:** Mostrar Cloudflare → CloudFront/AWS WAF → origem privada HTTPS, Web, RDS e Wazuh. Um Web, um NAT e RDS Single-AZ são limites da demonstração, não alta disponibilidade. (60 s)
7. **Vitor:** Explicar as verificações antes/durante/depois da VPN. O dispositivo MFA de Vitor foi observado; não foram auditados root, política global ou os demais integrantes. (45 s)
8. **Vitor:** Apontar os eventos 554/550/553 na árvore WordPress. FIM ajuda a detectar alterações e não comprova prevenção de ransomware. (50 s)
9. **Daniel:** Relacionar Cloudflare e AWS WAF aos testes correlacionados. Explicar limites diferentes e dizer que os ensaios não medem capacidade ou DDoS distribuído. (50 s)
10. **Daniel:** O ZAP público não encontrou High/Medium/Low no escopo testado; painel, plugins autenticados e checkout não foram cobertos. A restauração WordPress conferiu 52 tabelas e 8.808 arquivos, além de catálogo e busca HTTP 200. (60 s)
11. **Daniel:** Mostrar distribuição residual sem apresentar percentual de risco eliminado. Cinco cenários continuam altos, com controle e lacuna descritos. (45 s)
12. **Daniel:** Recomendar uso acadêmico até rever privilégio, kernel, testes autenticados, ransomware, dados e RPO/RTO. Acompanhar consumo institucional; nenhum recurso legado foi apagado. (40 s)

**Transição Artur → Vitor:** “Partimos desses 14 cenários. O Vitor mostra como os controles aparecem na arquitetura e nas evidências.”

**Transição Vitor → Daniel:** “Acesso e detecção estão demonstrados. O Daniel liga a proteção Web, a varredura e os limites às próximas decisões.”

## Demonstração e perguntas

Mostrar a loja final, buscar Caderno, exibir a captura do FIM e consultar os logs WAF já registrados. Evitar repetir teste de taxa durante a fala. Não mostrar senhas, chaves, tokens ou perfil VPN.

**É continuação dos roteiros?** Sim. É o mesmo caso ABC Place e preserva os 14 IDs do Roteiro 2. A VPC da final é evolução paralela, sem peering ou migração comercial.

**Todos os riscos foram eliminados?** Não. Cinco seguem altos e nove moderados. R01 é alto pela função administrativa usada; R03 permanece alto pela triagem do kernel. R06, R07 e R10 têm lacunas de validação para uso comercial.

**O SNS foi testado nesta integração?** Sim. Oito alarmes estão ligados ao SNS existente. Um teste de rede acionou ALARM e OK; o usuário confirmou receber ambos. Os oito voltaram a OK. Os demais alarmes não foram acionados individualmente.

**O scan WordPress ficou sem alertas?** Sem High/Medium/Low no escopo público, com 54 informativos. Painel, plugins autenticados, checkout e operação com dados reais não foram testados integralmente.

**O backup recupera a loja?** A recuperação integral conferiu banco, 8.808 arquivos, hashes, catálogo e busca na cópia isolada. Isso não define RPO/RTO comercial nem prova recuperação de uma conta/zona inteira.

**A avaliação não vai gastar dinheiro pessoal?** Nenhum meio de pagamento pessoal foi alterado e não foram criados EC2/RDS adicionais. A conta institucional ainda pode cobrar armazenamento, métricas, logs e uso contínuo; a fatura e um teto de gasto não foram verificados.
