# Custos e decisões para implantação

Nenhum recurso AWS foi criado nesta etapa. A proposta pode ser revisada no diretório `infra` antes de escolher conta, janela de uso e orçamento.

## Estimativa de planejamento

Para us-east-1, sem créditos, impostos ou câmbio, reservar aproximadamente **US$ 0,30 a US$ 0,40 por hora** de ambiente ativo, mais tráfego, processamento, logs e requisições. Esta faixa é uma estimativa de ordem de grandeza; a cotação precisa ser refeita para a conta e os preços vigentes antes de aplicar a configuração.

| Duração ativa | Parcela estimada pela faixa horária |
| --- | ---: |
| 6 horas | US$ 1,80 a US$ 2,40 |
| 24 horas | US$ 7,20 a US$ 9,60 |
| 730 horas | US$ 219 a US$ 292 |

O dimensionamento inclui três EC2, RDS, NAT Gateway, dois IPv4 públicos, armazenamento, cinco regras/grupos de WAF e monitoramento. O Wazuh concentra boa parte da capacidade de computação. Créditos e franquias, quando existirem, não foram considerados.

NAT Gateway, IPv4 público e WAF têm cobrança própria. Interromper apenas as EC2 mantém outros recursos cobrados. [Preços VPC](https://aws.amazon.com/vpc/pricing/), [preços WAF](https://aws.amazon.com/waf/pricing/), [preços EC2](https://aws.amazon.com/ec2/pricing/on-demand/), [preços RDS MySQL](https://aws.amazon.com/rds/mysql/pricing/).

## Informações necessárias para ativar

- Conta escolhida para este projeto novo e uma identidade nominal com as permissões necessárias.
- Limite de gasto autorizado e tempo em que o laboratório deve permanecer ativo.
- IPv4 público atual para restringir a entrada da VPN e chave SSH nova do operador.
- Decisão sobre domínio novo com certificado ACM. O domínio padrão CloudFront permite demonstração inicial, mas sua política mínima TLSv1 deve aparecer como pendência.
- Confirmação de que o cenário proposto pode ser usado, ou envio do relato específico desta avaliação, se houver.

As credenciais devem ser configuradas no computador ou pela sessão autorizada da AWS. Não devem entrar em arquivos versionados, imagens, mensagens ou slides.

## Encerramento

Ao terminar as evidências, exportar a entrega e conferir o plano de remoção apenas dos recursos com o prefixo desta avaliação. O RDS tem proteção contra exclusão e exige alteração deliberada antes de remover. O snapshot final, os backups retidos, os segredos em recuperação e os objetos de auditoria podem permanecer e gerar pequenas cobranças. O bucket de auditoria não é esvaziado automaticamente.

Um orçamento ou alarme de custo avisa sobre consumo; não constitui teto automático de cobrança.
