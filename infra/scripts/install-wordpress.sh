#!/usr/bin/env bash
# Pós-instalação revisada somente no Web da avaliação. Payload público em WORDPRESS_SOURCE_B64.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
python3 - <<'PY'
import json,re
c=json.load(open('/etc/cyberfinal.json'))
assert c['role']=='web' and re.fullmatch(r'cyberfinal262-[a-f0-9]{6}',c['project'])
PY
test -n "${WORDPRESS_SOURCE_B64:-}"
apt-get -o DPkg::Lock::Timeout=300 install -y php8.3-fpm php8.3-cli php8.3-mysql php8.3-curl php8.3-xml php8.3-mbstring php8.3-zip php8.3-gd php8.3-intl unzip gnupg >/dev/null
umask 077
install -d -m 0700 /root/abcplace-install
cd /root/abcplace-install
curl --fail --silent --show-error --location https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar -o wp-cli.phar
printf '%s  wp-cli.phar\n' 'ce34ddd838f7351d6759068d09793f26755463b4a4610a5a5c0a97b68220d85c' | sha256sum --check >/dev/null
install -m 0755 wp-cli.phar /usr/local/bin/wp
install -d -m 0755 /var/www/abcplace
if [ ! -s /var/www/abcplace/wp-load.php ]; then
    wp core download --version=7.1.5 --path=/var/www/abcplace --skip-content --allow-root >/dev/null
fi
export WORDPRESS_SOURCE_B64
python3 - <<'PY'
import base64,json,os,pathlib,secrets
import boto3,pymysql
c=json.load(open('/etc/cyberfinal.json'))
private=pathlib.Path('/root/abcplace-wordpress-private.json')
if private.exists():
    raise SystemExit('Instalação já iniciada; revisar o estado antes de repetir para não substituir segredos.')
v={'runtime_user':'abcplace_web','runtime_password':secrets.token_urlsafe(36),'setup_user':'abcplace_setup','setup_password':secrets.token_urlsafe(36),'wp_user':'vitor','wp_password':secrets.token_urlsafe(36)}
private.write_text(json.dumps(v));private.chmod(0o600)
master=json.loads(boto3.client('secretsmanager',region_name=c['region']).get_secret_value(SecretId=c['master_secret'])['SecretString'])
with pymysql.connect(host=c['database_host'],user=master['username'],password=master['password'],connect_timeout=8,ssl={'ca':'/opt/cyberfinal/rds-ca-bundle.pem','check_hostname':True}) as conn:
 with conn.cursor() as cur:
  cur.execute('CREATE DATABASE abcplace_wp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci')
  for role in ['setup','runtime']:
   cur.execute('CREATE USER %s@\'%%\' IDENTIFIED BY %s REQUIRE SSL',(v[role+'_user'],v[role+'_password']))
  cur.execute("GRANT ALL PRIVILEGES ON abcplace_wp.* TO 'abcplace_setup'@'%'")
  cur.execute("GRANT SELECT,INSERT,UPDATE,DELETE ON abcplace_wp.* TO 'abcplace_web'@'%'")
 conn.commit()
payload=json.loads(base64.b64decode(os.environ['WORDPRESS_SOURCE_B64']))
for name,value in payload.items():
 path=pathlib.Path('/var/www/abcplace/wp-content')/name
 assert '..' not in pathlib.PurePosixPath(name).parts and not name.startswith('/')
 path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(base64.b64decode(value));path.chmod(0o644)
config="<?php\n"
for k,value in {'DB_NAME':'abcplace_wp','DB_USER':v['setup_user'],'DB_PASSWORD':v['setup_password'],'DB_HOST':c['database_host'],'DB_CHARSET':'utf8mb4','DB_COLLATE':'','WP_DEBUG':False,'DISALLOW_FILE_EDIT':True,'DISALLOW_FILE_MODS':False,'DISABLE_WP_CRON':True,'AUTOMATIC_UPDATER_DISABLED':True}.items():
 config+='define('+json.dumps(k)+','+json.dumps(value)+");\n"
for key in ['AUTH_KEY','SECURE_AUTH_KEY','LOGGED_IN_KEY','NONCE_KEY','AUTH_SALT','SECURE_AUTH_SALT','LOGGED_IN_SALT','NONCE_SALT']:
 config+='define('+json.dumps(key)+','+json.dumps(secrets.token_urlsafe(48))+');\n'
config+="""
$local = isset($_SERVER['REMOTE_ADDR'],$_SERVER['HTTP_HOST']) && $_SERVER['REMOTE_ADDR']==='127.0.0.1' && in_array($_SERVER['HTTP_HOST'],['127.0.0.1:18080','127.0.0.1','10.62.10.10'],true);
$home=$local?'http://'.$_SERVER['HTTP_HOST']:'https://d3hc8whbcpdvtd.cloudfront.net';
define('WP_HOME',$home);define('WP_SITEURL',$home);
if (!$local) $_SERVER['HTTPS']='on';
$table_prefix='abc_';
if (!defined('ABSPATH')) define('ABSPATH',__DIR__.'/');
require_once ABSPATH.'wp-settings.php';
"""
path=pathlib.Path('/var/www/abcplace/wp-config.php');path.write_text(config);path.chmod(0o640)
PY
chown root:www-data /var/www/abcplace/wp-config.php
python3 - <<'PY'
import json,subprocess
v=json.load(open('/root/abcplace-wordpress-private.json'))
subprocess.run(['wp','core','install','--path=/var/www/abcplace','--url=https://d3hc8whbcpdvtd.cloudfront.net','--title=ABC Place','--admin_user='+v['wp_user'],'--admin_password='+v['wp_password'],'--admin_email=grupo09@example.invalid','--skip-email','--allow-root'],check=True,stdout=subprocess.DEVNULL)
PY
# O pacote é obtido do repositório oficial e verificado por checksums do WordPress.org.
wp plugin install woocommerce --version=11.3.1 --activate --path=/var/www/abcplace --allow-root >/dev/null
wp core verify-checksums --path=/var/www/abcplace --allow-root >/root/abcplace-install/core-checksums.txt
wp plugin verify-checksums woocommerce --path=/var/www/abcplace --allow-root >/root/abcplace-install/plugin-checksums.txt
wp theme activate abcplace --path=/var/www/abcplace --allow-root >/dev/null
wp option update blogdescription 'Continuidade dos roteiros do Grupo 09' --path=/var/www/abcplace --allow-root >/dev/null
wp option update users_can_register 0 --path=/var/www/abcplace --allow-root >/dev/null
wp option update default_comment_status closed --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_currency BRL --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_price_decimal_sep ',' --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_price_thousand_sep '.' --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_currency_pos left_space --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_enable_guest_checkout no --path=/var/www/abcplace --allow-root >/dev/null
wp option update woocommerce_allow_tracking no --path=/var/www/abcplace --allow-root >/dev/null
wp eval '
foreach ([["Caderno Horizonte","24.90"],["Garrafa do Projeto","59.90"],["Mochila Essencial","129.90"]] as $row) {
 $p=new WC_Product_Simple();$p->set_name($row[0]);$p->set_regular_price($row[1]);$p->set_status("publish");$p->set_catalog_visibility("visible");$p->set_virtual(true);$p->save();
}
WC_Install::create_tables();
' --path=/var/www/abcplace --allow-root >/dev/null
python3 - <<'PY'
import json,pathlib
import boto3,pymysql
c=json.load(open('/etc/cyberfinal.json'));v=json.load(open('/root/abcplace-wordpress-private.json'))
master=json.loads(boto3.client('secretsmanager',region_name=c['region']).get_secret_value(SecretId=c['master_secret'])['SecretString'])
with pymysql.connect(host=c['database_host'],user=master['username'],password=master['password'],ssl={'ca':'/opt/cyberfinal/rds-ca-bundle.pem','check_hostname':True}) as conn:
 with conn.cursor() as cur:cur.execute("DROP USER 'abcplace_setup'@'%'")
 conn.commit()
p=pathlib.Path('/var/www/abcplace/wp-config.php');s=p.read_text().replace(json.dumps(v['setup_user']),json.dumps(v['runtime_user'])).replace(json.dumps(v['setup_password']),json.dumps(v['runtime_password'])).replace('define("DISALLOW_FILE_MODS",false);','define("DISALLOW_FILE_MODS",true);');p.write_text(s);p.chmod(0o640)
v.pop('setup_password');v.pop('setup_user');pathlib.Path('/root/abcplace-wordpress-private.json').write_text(json.dumps(v))
PY
chown root:www-data /var/www/abcplace/wp-config.php
find /var/www/abcplace -type d -exec chmod 755 {} +
find /var/www/abcplace -type f ! -name wp-config.php -exec chmod 644 {} +
install -d -o www-data -g www-data -m 0750 /var/www/abcplace/wp-content/uploads
cat > /etc/php/8.3/fpm/conf.d/99-abcplace.ini <<'EOF'
expose_php=Off
display_errors=Off
log_errors=On
session.cookie_httponly=1
session.cookie_samesite=Lax
memory_limit=256M
upload_max_filesize=2M
post_max_size=2M
EOF
# Até dois workers para o t3.micro; não altera tamanho nem cria instâncias novas.
sed -i -e 's/^pm = .*/pm = ondemand/' -e 's/^pm.max_children = .*/pm.max_children = 2/' /etc/php/8.3/fpm/pool.d/www.conf
php-fpm8.3 -t
cp -n /etc/nginx/sites-available/cyberfinal /root/abcplace-install/nginx-before-wordpress.conf
cat > /etc/nginx/sites-available/cyberfinal <<'EOF'
log_format cyberfinal '$remote_addr $request_method $uri $status $body_bytes_sent';
server {
 listen 80 default_server;
 server_name _;
 root /var/www/abcplace;
 index index.php;
 server_tokens off;
 client_max_body_size 2m;
 access_log /var/log/nginx/access.log cyberfinal;
 add_header X-Content-Type-Options nosniff always;
 add_header X-Frame-Options DENY always;
 add_header Referrer-Policy no-referrer always;
 add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
 add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'" always;
 add_header Cache-Control no-store always;
 location = /healthz { proxy_pass http://127.0.0.1:8080; }
 location = /api/products { proxy_pass http://127.0.0.1:8080; }
 location ~ ^/(wp-login\.php|wp-admin|xmlrpc\.php|wp-json)(/|$) { return 403; }
 location ~ /\. { deny all; }
 location ~ ^/(wp-config\.php|readme\.html|license\.txt) { return 404; }
 location ~* /uploads/.*\.php$ { deny all; }
 location / { try_files $uri $uri/ /index.php?$args; }
 location ~ \.php$ {
  try_files $uri =404;
  include fastcgi_params;
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  fastcgi_pass unix:/run/php/php8.3-fpm.sock;
  fastcgi_hide_header X-Powered-By;
 }
}
EOF
nginx -t
systemctl restart php8.3-fpm
systemctl reload nginx
# Inclui a árvore WordPress em FIM, sem copiar senha ou conteúdo de wp-config para logs.
python3 - <<'PY'
from pathlib import Path
p=Path('/var/ossec/etc/ossec.conf');s=p.read_text()
if '/var/www/abcplace' not in s:s=s.replace('</syscheck>','<directories realtime="yes" check_all="yes">/var/www/abcplace</directories></syscheck>',1)
p.write_text(s)
PY
systemctl restart wazuh-agent
touch /var/lib/abcplace-wordpress-ready
wp eval 'global $wpdb; echo json_encode(["wordpress"=>get_bloginfo("version"),"woocommerce"=>WC_VERSION,"products"=>wp_count_posts("product")->publish,"db_tls"=>$wpdb->get_row("SHOW STATUS LIKE '\''Ssl_cipher'\''",ARRAY_A),"db_user"=>$wpdb->get_var("SELECT CURRENT_USER()")]);' --path=/var/www/abcplace --allow-root
echo
