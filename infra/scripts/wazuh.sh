#!/usr/bin/env bash
set -euo pipefail
source /etc/cyberfinal.env
umask 077
mkdir -p /root/cyberfinal-wazuh
cd /root/cyberfinal-wazuh
curl --fail --silent --show-error --retry 4 https://packages.wazuh.com/4.14/wazuh-install.sh -o wazuh-install.sh
printf '%s  wazuh-install.sh\n' "$WAZUH_INSTALLER_SHA256" | sha256sum --check --status
# O instalador imprime senhas; o log fica restrito ao root e fora do CloudWatch.
bash ./wazuh-install.sh -a > /root/cyberfinal-wazuh/install-private.log 2>&1
chmod -R go-rwx /root/cyberfinal-wazuh
if [ -f /etc/apt/sources.list.d/wazuh.list ]; then sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/wazuh.list; fi
systemctl is-active --quiet wazuh-manager
systemctl is-active --quiet wazuh-indexer
systemctl is-active --quiet wazuh-dashboard
touch /var/lib/cyberfinal-role-ready
