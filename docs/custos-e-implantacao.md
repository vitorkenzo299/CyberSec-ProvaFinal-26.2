# Consumo e encerramento

## Conta e limite pessoal

A avaliação reutiliza a conta institucional e os recursos existentes. O pagador é institucional; nenhum meio de pagamento pessoal foi incluído ou alterado. Não foram criadas novas instâncias EC2 ou RDS nem foi contratado plano pago Cloudflare. A zona Cloudflare continua no plano Free. Isso não garante custo zero para a instituição.

O backup WordPress deixou duas versões criptografadas, privadas e versionadas no bucket existente (aproximadamente 35,8 MB cada). Métricas adicionais do CloudWatch, logs e outros usos da conta também podem gerar cobranças institucionais. A revisão não consultou a fatura, não ativou um teto automático e não criou uma rotina diária de backup. Custos reais devem ser acompanhados no console de billing pela instituição.

## Recursos preservados

O subdomínio `final.abcplace.blog.br` foi adicionado ao DNS e à borda Cloudflare/CloudFront. Os registros de apex, `www` e monitoramento foram comparados e preservados. Os quatro servidores anteriores e os campos avaliados dos nove Security Groups não mudaram. A infraestrutura da final permanece ativa e separada, sem peering ou migração comercial.

O plano Terraform final não propõe alterações; nenhuma aplicação de plano foi necessária. As evidências e as duas versões de backup foram preservadas. Nenhum recurso, dado ou registro anterior foi apagado.

## Encerramento futuro

Os recursos atuais continuam consumindo na conta institucional. Se o grupo quiser encerrar a avaliação após a apresentação, deve identificar exclusivamente os recursos específicos da final, revisar snapshots, certificados, logs, alarmes e objetos versionados, confirmar retenção de evidências e obter autorização antes de qualquer remoção. Não usar comandos amplos de limpeza da conta. A interrupção de EC2 não interrompe todas as possíveis cobranças de rede, armazenamento, métricas ou logs.

A função de observação e snapshots/objetos de auditoria podem permanecer fora do estado Terraform atual. Um orçamento ou alarme de custo avisa sobre consumo; não funciona como bloqueio de cobrança. O ambiente precisa ser acompanhado pela instituição.
