# Versões e fontes da preparação

Verificação inicial em 21 de novembro de 2026. As versões abaixo descrevem a preparação local e não uma implantação AWS já executada.

| Componente | Versão ou referência |
| --- | --- |
| Terraform usado na validação | 1.13.5, pacote oficial Windows AMD64 com SHA-256 conferido |
| AWS provider selecionado | 6.73.0, fixado no arquivo de lock |
| Random provider selecionado | 3.9.1, fixado no arquivo de lock |
| Time provider selecionado | 0.14.2, fixado no arquivo de lock |
| Instalador Wazuh | Canal oficial 4.14; baixado para verificação de hash, sem executar |
| SHA-256 do instalador Wazuh | `db5f8d37703b3673ec0e6b30834499756cbd093d828fc24d7f5b276980ea1bf6` |
| Ubuntu previsto | AMI oficial Canonical 24.04 x86-64 mais recente no momento do plano real |
| RDS previsto | MySQL 8.4, versão secundária selecionada pela AWS no provisionamento |

Antes da implantação, conferir se o instalador Wazuh mantém o mesmo hash. Se a origem oficial tiver sido atualizada, revisar a alteração antes de mudar o hash esperado. O hash confirma integridade em relação ao arquivo revisado; não substitui a confiança na origem.

- [Pacotes Terraform oficiais](https://releases.hashicorp.com/terraform/1.13.5/)
- [Guia de instalação Wazuh](https://documentation.wazuh.com/current/quickstart.html)
- [Instalador oficial Wazuh 4.14](https://packages.wazuh.com/4.14/wazuh-install.sh)
- [Suporte RDS MySQL por classe](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Support.html)
- [Funcionamento da detecção de vulnerabilidades Wazuh](https://documentation.wazuh.com/current/user-manual/capabilities/vulnerability-detection/how-it-works.html)
- [Regras e referências entre Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html)

A detecção de vulnerabilidades Wazuh depende do inventário dos agentes e da correlação com inteligência de vulnerabilidades. A entrega deve registrar a atualização desses dados e a data dos achados, além do scan Web.
