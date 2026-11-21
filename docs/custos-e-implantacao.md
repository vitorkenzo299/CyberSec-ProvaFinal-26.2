# Custos e decisões para implantação

Nenhum recurso AWS foi criado nesta etapa. A proposta pode ser revisada no diretório `infra` antes de confirmar acesso, cobertura e janela de uso da conta acadêmica escolhida.

## Condição definida pelo aluno

Usar a conta acadêmica já existente, sem desembolso pessoal. Não excluir ou interromper o que já está pronto. A conta reutilizada não torna recursos novos gratuitos: é necessário verificar cobertura institucional ou créditos elegíveis antes de criar serviços. O limite pessoal autorizado é R$ 0; a estimativa abaixo é custo bruto de uma alternativa de infraestrutura, não autorização para cobrança ao aluno.

`funding_source_confirmed` é um valor obrigatório no Terraform. Se a cobertura não estiver confirmada, o plano é rejeitado. O exemplo mantém esse valor em `false`. Os testes usam cobertura fictícia apenas dentro de provedores simulados.

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

- Renovar o acesso à conta acadêmica existente com uma identidade nominal autorizada.
- Confirmar responsável pela cobrança, cobertura aplicável e janela de uso, preservando o limite pessoal de R$ 0.
- IPv4 público atual para restringir a entrada da VPN e chave SSH nova do operador.
- Decisão sobre domínio novo com certificado ACM. O domínio padrão CloudFront permite demonstração inicial, mas sua política mínima TLSv1 deve aparecer como pendência.
- Confirmação de que o cenário proposto pode ser usado, ou envio do relato específico desta avaliação, se houver.

As credenciais devem ser configuradas no computador ou pela sessão autorizada da AWS. Não devem entrar em arquivos versionados, imagens, mensagens ou slides.

## Encerramento

Ao terminar as evidências, exportar a entrega e conferir o plano de remoção apenas dos recursos com o prefixo desta avaliação. O RDS tem proteção contra exclusão e exige alteração deliberada antes de remover. O snapshot final, os backups retidos, os segredos em recuperação e os objetos de auditoria podem permanecer e gerar pequenas cobranças. O bucket de auditoria não é esvaziado automaticamente.

Um orçamento ou alarme de custo avisa sobre consumo; não constitui teto automático de cobrança. Não consultar a API paga do Cost Explorer durante a verificação inicial de cobertura; preferir o console gratuito e consultas de estado de conta que não tenham tarifa por requisição.
