# Roteiro individual de apresentação

Apresentador: **Vitor**. A apresentação tem 12 slides editáveis e notas de fala. Duração sugerida de 9 a 11 minutos, incluindo uma demonstração curta. Treinar a navegação antes da avaliação e usar as capturas preservadas se a sessão acadêmica estiver expirada.

| Slide | Mensagem e fala sugerida | Tempo |
| --- | --- | --- |
| 1 | “Criei um ambiente novo para demonstrar segurança de uma loja acadêmica, com dados fictícios e preservando o projeto anterior.” | 40 s |
| 2 | Explicar as sete condições hipotéticas que organizaram o diagnóstico. Elas não são uma auditoria do ambiente antigo. | 45 s |
| 3 | Relacionar credenciais, SQLi, malware, indisponibilidade e recuperação aos impactos no negócio. | 40 s |
| 4 | Explicar P×I e a matriz de 12 riscos. Dez altos iniciais, um alto residual. R05 permanece aberto. | 60 s |
| 5 | Mostrar o vínculo entre controle e teste: VPN, WAF, FIM e restauração. | 50 s |
| 6 | Percorrer o diagrama pelo caminho do cliente e pelo caminho administrativo. Distinguir duas zonas de alta disponibilidade. | 60 s |
| 7 | Mostrar que SSH só funcionou com a VPN, com login vitor e root e senha desativados. | 45 s |
| 8 | Localizar os três eventos do arquivo benigno e citar a regra 5712 do teste SSH. | 50 s |
| 9 | Mostrar os três bloqueios WAF e a correspondência dos logs. O limite por IP não é prova contra DDoS. | 50 s |
| 10 | Explicar a origem privada do ZAP, sem WAF, e a cópia restaurada com três linhas e hash igual. | 55 s |
| 11 | Explicar a comparação qualitativa, sem porcentagens inventadas. Destacar os limites. | 50 s |
| 12 | Recomendar fechar a triagem do kernel, TLS, MFA, escalonamento e redundância antes de dados reais. | 40 s |

## Demonstração curta

1. Abrir o catálogo público e realizar uma busca legítima.
2. Com a VPN conectada, abrir o Wazuh como vitor e mostrar os eventos já gerados. Não exibir senhas, chave, token ou perfil VPN.
3. Mostrar o WAF em modo de consulta e os registros dos testes. Não repetir a sequência de taxa durante a fala, pois o bloqueio temporário poderia afetar a demonstração do próprio operador.
4. Encerrar com a comparação do snapshot e a limitação de R05.

## Perguntas esperadas

**Todos os riscos altos foram eliminados?** Não. R05 continua alto e justificado com evidências. Os demais receberam controles e limitações documentadas.

**ZAP sem alertas significa ambiente sem vulnerabilidades?** Não. O resultado é do catálogo e das regras executadas. O inventário do sistema operacional é outra análise e permanece em triagem.

**Por que WAF e consulta parametrizada?** O WAF inspeciona a borda. A consulta parametrizada protege o acesso a dados mesmo quando a aplicação é alcançada pelo caminho interno autorizado.

**O ambiente tem alta disponibilidade?** Não. As sub-redes estão em duas zonas, mas o Web, o NAT e o RDS usam componentes únicos.

**O trabalho anterior foi alterado?** Os quatro servidores e as regras dos nove SG anteriores foram comparados com o inventário inicial e permaneceram iguais nos campos avaliados.
