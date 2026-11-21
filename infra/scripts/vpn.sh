#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
source /etc/cyberfinal.env
export AWS_DEFAULT_REGION=us-east-1
umask 077
apt-get -o DPkg::Lock::Timeout=300 install -y openvpn easy-rsa iptables-persistent
[ -d /etc/openvpn/easy-rsa ] || make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
export EASYRSA_BATCH=1 EASYRSA_ALGO=ec EASYRSA_CURVE=prime256v1
unset EASYRSA_REQ_CN || true
[ -d pki ] || ./easyrsa init-pki
[ -s pki/ca.crt ] || EASYRSA_REQ_CN="$PROJECT-CA" ./easyrsa build-ca nopass
[ -s pki/issued/server.crt ] || ./easyrsa build-server-full server nopass
[ -s "pki/issued/$OPERATOR.crt" ] || ./easyrsa build-client-full "$OPERATOR" nopass
./easyrsa gen-crl
[ -s /etc/openvpn/server/tls-crypt.key ] || openvpn --genkey secret /etc/openvpn/server/tls-crypt.key
cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn/server/
chmod 644 /etc/openvpn/server/ca.crt /etc/openvpn/server/server.crt /etc/openvpn/server/crl.pem
cat > /etc/openvpn/server/server.conf <<EOF
port 1194
proto udp
dev tun
topology subnet
server 10.99.0.0 255.255.255.0
ca ca.crt
cert server.crt
key server.key
crl-verify crl.pem
dh none
ecdh-curve prime256v1
tls-crypt tls-crypt.key
tls-version-min 1.2
data-ciphers AES-256-GCM:AES-128-GCM
auth SHA256
push "route $WEB_IP 255.255.255.255"
push "route $WAZUH_IP 255.255.255.255"
user nobody
group nogroup
persist-key
persist-tun
keepalive 10 120
verb 3
status /run/openvpn-server/cyberfinal-status.log
EOF
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/90-cyberfinal-vpn.conf
sysctl --system >/dev/null
# A VPN oferece somente administração dos dois destinos definidos.
IFACE=$(ip -o -4 route show default | awk '{print $5;exit}')
if command -v ufw >/dev/null 2>&1; then ufw disable; fi
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p udp --sport 67 --dport 68 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun0 -p tcp --dport 22 -j ACCEPT
iptables -P FORWARD DROP
# Evita fragmentacao do TCP encapsulado no acesso administrativo por UDP.
iptables -t mangle -A FORWARD -i tun0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1200
iptables -t mangle -A FORWARD -o tun0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1200
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
for target in "$WEB_IP" "$WAZUH_IP"; do
  iptables -A FORWARD -i tun0 -s "$VPN_CIDR" -d "$target" -p tcp --dport 22 -j ACCEPT
done
for port in 443 55000; do iptables -A FORWARD -i tun0 -s "$VPN_CIDR" -d "$WAZUH_IP" -p tcp --dport "$port" -j ACCEPT; done
iptables -t nat -A POSTROUTING -s "$VPN_CIDR" -d "$VPC_CIDR" -o "$IFACE" -j MASQUERADE
netfilter-persistent save
systemctl enable --now openvpn-server@server
python3 - <<'PY'
import json,pathlib,urllib.request,boto3
c=json.load(open('/etc/cyberfinal.json'))
token=urllib.request.urlopen(urllib.request.Request('http://169.254.169.254/latest/api/token',data=b'',method='PUT',headers={'X-aws-ec2-metadata-token-ttl-seconds':'60'}),timeout=5).read().decode()
ip=urllib.request.urlopen(urllib.request.Request('http://169.254.169.254/latest/meta-data/public-ipv4',headers={'X-aws-ec2-metadata-token':token}),timeout=5).read().decode().strip()
p=pathlib.Path('/etc/openvpn/easy-rsa/pki')
profile='client\ndev tun\nproto udp\nremote '+ip+' 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nremote-cert-tls server\nverify-x509-name server name\ntls-version-min 1.2\ndata-ciphers AES-256-GCM:AES-128-GCM\nauth SHA256\nverb 3\n'
for tag,file in [('ca',p/'ca.crt'),('cert',p/'issued'/f"{c['operator']}.crt"),('key',p/'private'/f"{c['operator']}.key"),('tls-crypt',pathlib.Path('/etc/openvpn/server/tls-crypt.key'))]:
    text=file.read_text(); begin=text.index('-----BEGIN'); text=text[begin:]
    profile+=f'<{tag}>\n{text.strip()}\n</{tag}>\n'
boto3.client('ssm',region_name=c['region']).put_parameter(Name=c['vpn_parameter'],Type='SecureString',Value=profile,Overwrite=True)
PY
touch /var/lib/cyberfinal-role-ready
