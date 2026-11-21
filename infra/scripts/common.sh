#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export AWS_DEFAULT_REGION=us-east-1
umask 077
apt-get -o DPkg::Lock::Timeout=300 update
apt-get -o DPkg::Lock::Timeout=300 install -y python3-boto3 python3-pymysql curl jq ca-certificates gnupg ufw auditd rsyslog unattended-upgrades

python3 - <<'PY'
import json, pathlib, shlex
c = json.load(open('/etc/cyberfinal.json'))
pathlib.Path('/etc/cyberfinal.env').write_text('\n'.join(k.upper()+'='+shlex.quote(str(v)) for k,v in c.items() if isinstance(v,str))+'\nAWS_DEFAULT_REGION=us-east-1\n')
PY
source /etc/cyberfinal.env
cat > /etc/ssh/sshd_config.d/00-cyberfinal.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
MaxAuthTries 3
AllowUsers $OPERATOR
EOF
sshd -t
systemctl reload ssh
systemctl enable --now auditd
cat > /etc/audit/rules.d/cyberfinal.rules <<'EOF'
-w /etc/ssh/ -p wa -k ssh_configuration
-w /etc/sudoers -p wa -k privilege_configuration
-w /etc/sudoers.d/ -p wa -k privilege_configuration
EOF
augenrules --load
ufw default deny incoming
ufw default allow outgoing
if [ "$ROLE" = web ]; then ufw allow 80/tcp; fi
if [ "$ROLE" != vpn ]; then ufw allow from "$VPN_IP" to any port 22 proto tcp; fi
if [ "$ROLE" = wazuh ]; then
  for port in 1514 1515; do
    ufw allow from "$WEB_IP" to any port "$port" proto tcp
    ufw allow from "$VPN_IP" to any port "$port" proto tcp
  done
  for port in 443 55000; do ufw allow from "$VPN_IP" to any port "$port" proto tcp; done
else
  curl --fail --silent --show-error --retry 4 https://packages.wazuh.com/key/GPG-KEY-WAZUH -o /tmp/wazuh-signing.key
  gpg --batch --yes --dearmor -o /usr/share/keyrings/wazuh.gpg /tmp/wazuh-signing.key
  chmod 644 /usr/share/keyrings/wazuh.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main' > /etc/apt/sources.list.d/wazuh.list
  apt-get -o DPkg::Lock::Timeout=300 update
  WAZUH_MANAGER="$WAZUH_IP" WAZUH_AGENT_NAME="$PROJECT-$ROLE" apt-get -o DPkg::Lock::Timeout=300 install -y wazuh-agent='4.14.*'
  python3 - <<'PY'
import xml.etree.ElementTree as E
p='/var/ossec/etc/ossec.conf'
# O arquivo Wazuh pode conter múltiplos elementos ossec_config.
text=open(p).read(); text=text.replace('</syscheck>', '<directories realtime="yes">/opt/cyberfinal</directories></syscheck>', 1)
if '<localfile>' not in text or '/var/log/auth.log' not in text:
    text=text.replace('</ossec_config>', '<localfile><log_format>syslog</log_format><location>/var/log/auth.log</location></localfile></ossec_config>',1)
open(p,'w').write(text)
PY
  mkdir -p /opt/cyberfinal
  systemctl enable --now wazuh-agent
  apt-mark hold wazuh-agent
  sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/wazuh.list
fi
if [ "$ROLE" != vpn ]; then ufw --force enable; fi

# Logs centralizados sem query strings ou credenciais.
curl --fail --silent --show-error --retry 4 https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -o /tmp/cloudwatch-agent.deb
dpkg -i /tmp/cloudwatch-agent.deb
python3 - <<'PY'
import json, pathlib
c=json.load(open('/etc/cyberfinal.json'))
paths=['/var/log/syslog','/var/log/auth.log','/var/log/audit/audit.log']
if c['role']=='web': paths+=['/var/log/nginx/access.log','/var/log/nginx/error.log']
entries=[{'file_path':p,'log_group_name':c['system_log_group'],'log_stream_name':'{instance_id}/'+pathlib.Path(p).name} for p in paths]
pathlib.Path('/opt/aws/amazon-cloudwatch-agent/etc/cyberfinal.json').write_text(json.dumps({'logs':{'logs_collected':{'files':{'collect_list':entries}}}}))
PY
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/cyberfinal.json
touch /var/lib/cyberfinal-common-ready
