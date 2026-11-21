# Procedimentos de implantação e validação

Os comandos desta página são um roteiro para o ambiente novo na conta acadêmica existente. A implantação só deve começar depois de confirmar cobertura sem desembolso pessoal e revisar o plano real. Nesta etapa, os únicos testes executados são locais e simulados.

## Preparação

1. Confirmar o cenário do trabalho e os integrantes. O nome Aurora é provisório.
2. Configurar uma identidade AWS nominal autorizada para a conta escolhida, sem publicar credenciais.
3. Gerar uma chave SSH nova e manter a chave privada em `.local` ou em outro local protegido. Usar apenas a chave pública no Terraform.
4. Conferir o IPv4 público atual do operador e usar `/32` na VPN.
5. Baixar o instalador oficial `https://packages.wazuh.com/4.14/wazuh-install.sh`, revisar sua origem e registrar o SHA-256 em `wazuh_installer_sha256`.
6. Copiar `infra/terraform.tfvars.example` para `infra/terraform.tfvars` e preencher os valores escolhidos. Este arquivo é ignorado pelo Git.
7. Configurar armazenamento confidencial do estado Terraform. Preferir backend S3 próprio com criptografia, bloqueio de acesso público, versionamento, bloqueio de estado e permissões restritas. Nunca colocar o estado no Git.
8. Conferir permissões e quotas da conta. As três EC2 propostas totalizam 8 vCPU da família Standard; contas novas ou Academy podem exigir ajuste de quota ou de arquitetura. Conferir também disponibilidade de RDS, WAF, CloudFront VPC Origin e criação de roles.
9. Registrar um inventário privado dos recursos existentes. Confirmar o pagador e a cobertura acadêmica antes de definir `funding_source_confirmed = true`. O limite de desembolso pessoal é R$ 0.

## Validação sem nuvem

```powershell
python -m unittest discover -s tests -v
terraform -chdir=infra init -backend=false
terraform -chdir=infra validate
terraform -chdir=infra test
```

Todos os provedores externos do teste são simulados. O teste utiliza `command = apply` no ambiente de mocks para avaliar atributos resolvidos; isso não aplica infraestrutura na AWS.

## Implantação depois das decisões

```powershell
terraform -chdir=infra init
terraform -chdir=infra plan -out=../.local/lab.tfplan
terraform -chdir=infra show ../.local/lab.tfplan
```

Revisar a conta e cada criação, confirmar que não há recursos importados de outros projetos e confrontar a lista com o orçamento. Com o plano aprovado, aplicar exatamente o arquivo revisado:

Antes da aplicação, salvar a saída de `terraform show -json` do plano em arquivo privado UTF-8 e passar pelo verificador:

```powershell
python scripts/review_plan.py --plan-json .local/plan.json --account CONTA_ACADEMICA_ESCOLHIDA
```

Atualizações, exclusões e substituições são recusadas no plano inicial, preservando o trabalho anterior. O verificador não comprova cobertura financeira; essa confirmação precisa existir antes.

```powershell
terraform -chdir=infra apply ../.local/lab.tfplan
terraform -chdir=infra output
```

Provisionamento concluído não comprova que a instalação inicial terminou. Conferir `/var/lib/cyberfinal-common-ready`, `/var/lib/cyberfinal-role-ready` e os serviços em cada EC2. O instalador Wazuh pode levar vários minutos. Seu log privado contém credenciais de bootstrap e fica fora da coleta CloudWatch.

A permissão para o segredo privilegiado do RDS expira duas horas após a criação do banco. Se o bootstrap Web falhar e essa janela passar, revisar a causa e conceder uma nova janela limitada deliberadamente; recriar a EC2 sem tratar esse ponto não resolve o acesso expirado.

## VPN e administração

Recuperar o perfil VPN do parâmetro SecureString cujo nome aparece no output `vpn_profile_parameter`. Salvar diretamente em arquivo privado; não mostrar o valor no terminal nem colocá-lo no repositório.

Registrar as três situações: antes do túnel, durante o túnel e depois da desconexão. Durante a conexão, acessar por SSH com o usuário nominal os endereços privados Web e Wazuh. Os endereços públicos não devem oferecer SSH. O firewall da VPN limita encaminhamento a esses destinos e às portas de administração.

Criar um usuário nominal no Wazuh com permissão adequada à demonstração. Preservar o segredo da conta de bootstrap em local privado e não utilizá-la como identidade cotidiana nas evidências.

## Testes e provas

| Controle | Ação limitada ao laboratório | Resultado necessário |
| --- | --- | --- |
| Inventário | Conferir VPC, sub-redes, EC2 e RDS por tags e IDs do Terraform | Recursos novos e rede compatível com o diagrama |
| IAM | Identificar operador e inspecionar políticas das roles | Operador nominal e ausência de permissão administrativa genérica nas cargas |
| Rede | Testar portas a partir de origens permitidas e não permitidas | Administração pelo túnel e MySQL apenas do Web |
| VPN | Comparar conexão aos endereços privados antes, durante e depois | Caminho privado disponível durante o túnel |
| Wazuh | Criar, alterar e remover arquivo benigno em `/opt/cyberfinal` | Eventos FIM datados e associados ao agente |
| Autenticação | Gerar poucas falhas controladas com usuário inexistente | Eventos de autenticação observados, sem carga excessiva |
| WAF | Executar quatro requisições do script abaixo | Saúde 200, marcador bloqueado 403 e catálogo legítimo preservado |
| SQLi | Conferir grupo gerenciado e resultado do payload de assinatura | Resultado ligado à regra real; não extrapolar para ausência de SQLi |
| Vulnerabilidades | Rodar ZAP e avaliação de pacotes dos agentes com versão e escopo registrados | Corrigir achados altos e repetir a análise |
| Backup | Restaurar snapshot RDS em cópia separada, privada e identificada para teste | Comparar catálogo, registrar duração e remover apenas a cópia de teste |

O teste de restauração cria uma cópia temporária do banco e deve integrar o orçamento antes da execução.

O scan da aplicação deve incluir um caminho privado autorizado, por exemplo um túnel SSH local pelo VPN, além da avaliação da borda pública. Um WAF pode bloquear o scanner antes de ele avaliar a aplicação; não interpretar esse bloqueio como ausência de vulnerabilidades. Registrar separadamente os dois escopos.

```powershell
python scripts/test_waf.py https://DOMINIO-DESTE-LABORATORIO
```

O marcador `x-cyberfinal-test: blocked` prova uma regra sintética de bloqueio. O script também observa uma assinatura SQLi, mas esse resultado precisa ser interpretado separadamente. Quatro requisições não comprovam rate limiting ou resistência a DDoS. Para o rate limiting, definir um teste próprio com volume, janela e parada controlados.

## Coleta

Salvar `terraform output -json` em arquivo privado UTF-8, por exemplo `.local/deployment.json`. Depois, executar a coleta com a conta escolhida:

```powershell
python scripts/collect_aws.py --outputs .local/deployment.json --account CONTA_ESCOLHIDA
python scripts/evidence_manifest.py
```

O coletor aceita somente os IDs dos outputs, exige tags do projeto para EC2 e RDS, mascara o número da conta nos registros e não recupera segredos. Uma coleta parcial interrompida deve ser marcada como incompleta; os JSONs não substituem os prints dos painéis.

Para cada captura, mostrar data, recurso, regra ou evento e contexto suficiente para identificar o resultado. Fechar ou ocultar telas com senhas, chaves, perfil VPN, cookies e tokens antes de capturar. Não substituir telas reais por montagens de painéis.

## Encerramento

Exportar evidências e relatório antes de remover o laboratório. Revisar `terraform plan -destroy`, o snapshot final, os backups e a auditoria retidos. A proteção do RDS e os objetos do bucket exigem tratamento deliberado. Ao final, conferir a conta por tags para localizar cobranças remanescentes deste projeto.
