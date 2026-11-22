# Procedimentos de implantação e validação

Os comandos desta página são um roteiro para o ambiente novo na conta acadêmica existente. A implantação só deve começar depois de confirmar cobertura sem desembolso pessoal e revisar o plano real. A implantação e os testes reais foram executados em 21/11/2026. Este roteiro documenta a retomada e uma futura implantação isolada.

## Preparação

1. A apresentação é do Grupo 09: Vitor, Artur Cruz e Daniel Juho. A aplicação principal é a ABC Place em WordPress/WooCommerce, na continuidade dos roteiros 1 a 4.
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


## Estado atual e retomada

Projeto `cyberfinal262-5f48e9`, VPC `vpc-013c42b2a693efb40`. A aplicação está em https://d3hc8whbcpdvtd.cloudfront.net. Web: `10.62.10.10`; Wazuh: `https://10.62.10.20` pela VPN. O perfil privado se chama `cyberfinal-vitor.ovpn`. O Windows usa o OpenVPN GUI com o serviço interativo instalado. Ele evita a necessidade de executar manualmente o cliente com privilégios de rede.

A chave privada, o perfil VPN, as credenciais de consulta e os outputs ficam em `.local/auth` ou `.local/deployment.json`, excluídos do Git. Não imprimir nem compartilhar esses arquivos. O parâmetro SSM do perfil é `/cyberfinal262-5f48e9/vpn/client`. A senha de vitor no Wazuh fica no arquivo privado `wazuh-viewer.json`. O acesso ao console AWS deve usar SSO e a função observer de consulta. Uma nova sessão pode ser necessária após expirar a autenticação.

`deployment_suffix` é um identificador estável de seis caracteres hexadecimais que deve ser definido antes do primeiro plano. Para outro laboratório, gerar um sufixo novo e manter o valor até seu encerramento. Não alterar o sufixo de um ambiente existente. O nome da implantação atual não deve ser reutilizado para criar um segundo laboratório.

O estado Terraform atual usa bucket S3 próprio privado com criptografia, versionamento e bloqueio por lockfile. A configuração confidencial do backend está em `.local/backend.hcl`. Não publicar o estado, o plano nem o arquivo de variáveis.

Os dados cloud-init são de primeiro uso. `ignore_changes = [user_data_base64]` evita recriar instâncias por um ajuste de instalação. Uma mudança posterior exige atualização explícita e revisada nos hosts novos; apenas rodar apply não atualiza o software existente. A primeira instalação precisou de correções de rede, SSH, permissões de diretório, PKI e MSS, já incorporadas às fontes.

A função observer foi criada no pós-provisionamento, fora do estado Terraform. Seu nome, política e teste IAM estão em EV02. O usuário Wazuh também é uma configuração de pós-instalação. Incluir ambos no inventário de encerramento; não assumir que terraform destroy remove todas as configurações adicionais.

O snapshot de evidência é `cyberfinal262-5f48e9-evidence-20261121`. A instância temporária `cyberfinal262-5f48e9-restore-20261121` já foi removida. A instância principal e o snapshot foram preservados. R03 não deve ser encerrado com base somente no ZAP: conferir `triagem-kernel.json` e o inventário Wazuh.


## Pós instalação reproduzível

A função de consulta pode ser criada com `python scripts/configure_observer.py --outputs .local/deployment.json --account CONTA_ESCOLHIDA` usando a sessão nominal de implantação. O comando valida a conta e a tag de projeto e não exporta credenciais. O script `infra/scripts/create-wazuh-viewer.sh` configura o usuário de leitura somente em um host Wazuh deste projeto. Inicializar as visualizações uma vez com a conta de instalação e retornar ao usuário vitor. O script não imprime a senha e informa o arquivo privado no servidor.


## Continuidade WordPress da ABC Place

A aplicação principal agora é WordPress/WooCommerce no mesmo Web privado e no mesmo RDS existente, com schema `abcplace_wp`. A instalação pós-provisionamento não é feita automaticamente por `terraform apply`: suas fontes estão em `wordpress/` e `infra/scripts/install-wordpress.sh`. O script recusa sobrescrever a guarda privada de uma instalação já iniciada. Para atualizar uma instalação existente, revisar mudanças e executar uma manutenção explícita, preservando banco, fontes e backups.

Para preparar somente as fontes públicas: `python scripts/pack_wordpress.py --output .local/install-wordpress-packed.sh`. A execução exige host Web validado e uma permissão de manutenção de curta duração, restrita ao segredo mestre desse RDS. A permissão não deve ser renovada para o uso diário. Na execução desta avaliação, ela foi removida após o setup e a conta SQL temporária foi excluída. O WordPress diário usa `abcplace_web`, sem DDL, apenas no schema próprio. Atualizações que exigem migração de tabelas precisam de manutenção controlada.

Manutenção nominal: conectar a VPN, usar SSH como vitor e elevar explicitamente para WP-CLI. A interface pública `/wp-admin` e `/wp-login.php` foi bloqueada; não compartilhar a sessão nominal de Vitor com os colegas. Conceder acesso próprio aos integrantes quando necessário. A senha privada da conta WordPress nominal e o segredo do banco estão apenas no servidor, fora do Git. A configuração PHP fica em 640 root:www-data; arquivos públicos ficam em 644 e diretórios em 755, com escrita de uploads limitada.

`scripts/verify_wordpress.sh` verifica versões, checksums oficiais, grants, TLS (incluindo CA e hostname incorretos) e respostas HTTP sem imprimir segredos. O tema serve catálogo acadêmico sem checkout, cadastro de clientes ou pagamentos. Atualizações automáticas e edição pela interface foram desabilitadas; manter rotina de atualização revisada. Restauração integral de WordPress e dados reais não foi demonstrada.
