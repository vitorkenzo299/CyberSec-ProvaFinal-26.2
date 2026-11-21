# Avaliação final de Cibersegurança 2026.2

Apresentação individual de **Vitor**. Ambiente novo implantado na conta institucional do curso, em VPC própria, preservando o trabalho anterior. A loja fictícia Aurora materializa o caso acadêmico ABC Place citado no enunciado e usa somente três produtos sintéticos, sem pagamentos ou dados pessoais.

**Aplicação:** [abrir o catálogo na AWS](https://d3hc8whbcpdvtd.cloudfront.net).

VPN, WAF, agentes Wazuh, permissões de consulta e restauração do banco foram testados. A avaliação Web com ZAP terminou sem alertas no escopo executado. **R05 continua alto:** o inventário de pacotes do kernel contém correlações High e Critical em triagem. Os resultados não representam aprovação para produção.

## Entrega

- [Relatório em PDF](entrega/Relatorio_Final_Ciberseguranca.pdf) e [versão Word editável](entrega/Relatorio_Final_Ciberseguranca.docx)
- [Apresentação editável de 12 slides](entrega/Apresentacao_Executiva.pptx) e [PDF dos slides](entrega/Apresentacao_Executiva.pdf)
- [Matriz de riscos em Excel](entrega/Matriz_de_Riscos.xlsx)
- [Todas as evidências e fotos](entrega/Evidencias_Completas.zip), [índice por controle](evidencias/INDICE.md) e [manifesto SHA-256](evidencias/manifesto.json)
- [Roteiro individual de apresentação](docs/roteiro-apresentacao.md)

## Resultados práticos

| Controle | Prova registrada |
| --- | --- |
| VPN | SSH privado inacessível sem o túnel e acessível durante; login nominal vitor e AES-256-GCM |
| Privilégios | Wazuh negou administração de usuários com 403; simulação IAM permitiu leitura e negou ações de alteração |
| WAF | Probe 403, assinatura SQLi 403 e bloqueio por taxa no pedido 128, ligados a regras distintas nos logs |
| Wazuh | Dois agentes ativos, eventos FIM 554/550/553 e força bruta SSH 5712 |
| ZAP 2.17.0 | 930 mensagens e 12 URLs na sessão pela origem privada; 100% concluído e fila passiva zerada |
| Recuperação | Snapshot restaurado em cópia privada; três linhas com SHA-256 igual; cópia temporária removida |
| Preservação | Quatro instâncias antigas com os mesmos campos comparados e regras dos nove SG anteriores iguais |

As estimativas iniciais da matriz são hipóteses sem os controles. A classificação residual é julgamento qualitativo apoiado nos testes, sem cálculo estatístico de redução de risco.

## Ambiente e operação

Projeto `cyberfinal262-5f48e9`, VPC `10.62.0.0/16`, região `us-east-1`. Web e Wazuh não têm IP público. RDS MySQL privado aceita 3306 somente do Web. A VPN recebe UDP 1194 de um IPv4 /32 autorizado. CloudFront usa VPC Origin e WAF.

- [Arquitetura e limites](docs/arquitetura.md)
- [Matriz completa e justificativas](docs/matriz-de-riscos.md)
- [Procedimentos e retomada](docs/operacao.md)
- [Consumo e encerramento](docs/custos-e-implantacao.md)
- [Status e limitações](docs/status.md)
- [Versões e fontes oficiais](docs/versoes-e-fontes.md)

Um único Web, NAT e RDS Single-AZ limitam disponibilidade. O certificado padrão CloudFront mantém política mínima TLSv1 e a origem privada usa HTTP. MFA e notificação externa não foram comprovados. A cobertura institucional foi verificada, mas isso não torna os serviços gratuitos ou limita automaticamente o consumo. Os recursos novos permanecem identificados para a demonstração; o encerramento deve preservar o projeto anterior.

## Executar e verificar localmente

```powershell
python app/server.py --demo
python -m unittest discover -s tests -v
terraform -chdir=infra validate
terraform -chdir=infra test
```

O modo local usa catálogo em memória. Na AWS a aplicação lê MySQL com TLS e Secrets Manager, sem permissão de escrita. Os testes Terraform usam provedores simulados e não criam recursos.

Chaves, senhas, perfis VPN, credenciais temporárias, planos e estado Terraform ficam excluídos do Git. O estado remoto tem bucket privado próprio. O código Terraform e os procedimentos de pós-instalação registram o ambiente desta avaliação.
