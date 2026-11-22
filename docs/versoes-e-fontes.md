# Versões e fontes

Verificação inicial em 21 de novembro de 2026. As versões e registros abaixo apoiam a implantação e os testes realizados nesta avaliação.

| Componente | Versão ou referência |
| --- | --- |
| Terraform usado na validação | 1.13.5, pacote oficial Windows AMD64 com SHA-256 conferido |
| AWS provider selecionado | 6.73.0, fixado no arquivo de lock |
| Random provider selecionado | 3.9.1, fixado no arquivo de lock |
| Time provider selecionado | 0.14.2, fixado no arquivo de lock |
| Instalador Wazuh | Canal oficial 4.14; instalado nos hosts novos, versão observada 4.14.10 |
| SHA-256 do instalador Wazuh | `db5f8d37703b3673ec0e6b30834499756cbd093d828fc24d7f5b276980ea1bf6` |
| Ubuntu observado | Ubuntu 24.04.5 LTS, kernel 7.0.0-1018-aws conforme inventário |
| RDS implantado | MySQL 8.4, versão secundária selecionada pela AWS no provisionamento |

Antes da implantação, conferir se o instalador Wazuh mantém o mesmo hash. Se a origem oficial tiver sido atualizada, revisar a alteração antes de mudar o hash esperado. O hash confirma integridade em relação ao arquivo revisado; não substitui a confiança na origem.

- [Pacotes Terraform oficiais](https://releases.hashicorp.com/terraform/1.13.5/)
- [Guia de instalação Wazuh](https://documentation.wazuh.com/current/quickstart.html)
- [Instalador oficial Wazuh 4.14](https://packages.wazuh.com/4.14/wazuh-install.sh)
- [Suporte RDS MySQL por classe](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Support.html)
- [Funcionamento da detecção de vulnerabilidades Wazuh](https://documentation.wazuh.com/current/user-manual/capabilities/vulnerability-detection/how-it-works.html)
- [Regras e referências entre Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html)

A detecção de vulnerabilidades Wazuh depende do inventário dos agentes e da correlação com inteligência de vulnerabilidades. A entrega deve registrar a atualização desses dados e a data dos achados, além do scan Web.


OWASP ZAP 2.17.0, pacote oficial com SHA-256 `94c8f767b1c2e94f0db66b3ae56514d5e3f5a728ee1b6c798e0c8fe2d61fbff0`. A sessão registrou 930 mensagens e 12 URLs, com scan ativo concluído e fila passiva vazia. [Versão oficial](https://github.com/zaproxy/zaproxy/releases/tag/v2.17.0).

A amostra do inventário CVE-2026-98367 foi comparada à [fonte Canonical](https://ubuntu.com/security/CVE-2026-98367). A versão instalada é posterior à correção indicada para linux-aws-7.0, mas os demais achados não foram automaticamente considerados falsos positivos. R03 permanece alto.

O relatório foi aberto e exportado pelo Word instalado. Os slides foram abertos no PowerPoint, além das verificações de estrutura, fontes, tabelas e dados do gráfico. A matriz foi calculada e verificada com alteração de entrada e teste de entrada ausente. Os arquivos finais não dependem de uma sessão AWS ativa para leitura.


## Plataforma ABC Place na evolução final

WordPress 7.1.5, WooCommerce 11.3.1, PHP 8.3.6 e WP-CLI 2.12.0 foram observados em 22/11 UTC (21/11 em Brasília). O PHAR do WP-CLI foi fixado por SHA-256 `ce34ddd838f7351d6759068d09793f26755463b4a4610a5a5c0a97b68220d85c`. Núcleo WordPress e plugin WooCommerce passaram no verificador oficial de checksums. Integridade de pacote não prova ausência de vulnerabilidades.

- [Instalação WordPress com WP-CLI](https://developer.wordpress.org/cli/commands/core/install/)
- [Verificação de downloads WP-CLI](https://make.wordpress.org/cli/handbook/guides/verifying-downloads/)
- [Verificador de checksums](https://developer.wordpress.org/cli/commands/core/verify-checksums/)
- [Interface wpdb para conexão e drop-in](https://developer.wordpress.org/reference/classes/wpdb/)
- [Requisitos WooCommerce](https://woocommerce.com/document/update-php-wordpress/)

O novo scan WordPress tem 1.232 registros HTTP e 16 formas de URL (12 endpoints no sumário HTML), 54 informativos e nenhum High/Medium/Low. Ele não substitui o scan anterior do catálogo Python nem o inventário do SO. Nomes, versões e hashes dos roteiros 1–4 estão em `evidencias/continuidade/fontes.json`. O original foi apenas lido; sua escala de quatro níveis foi preservada na matriz.
