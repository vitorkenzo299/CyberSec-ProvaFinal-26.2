#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
source /etc/cyberfinal.env
export AWS_DEFAULT_REGION APP_SECRET_ARN="$APP_SECRET" DB_HOST="$DATABASE_HOST"
umask 077
apt-get -o DPkg::Lock::Timeout=300 install -y nginx
id cyberapp >/dev/null 2>&1 || useradd --system --shell /usr/sbin/nologin --home-dir /opt/cyberfinal cyberapp
mkdir -p /opt/cyberfinal
python3 - <<'PY'
import base64,json,pathlib
c=json.load(open('/etc/cyberfinal.json'))
for name,data in c['application'].items():
    p=pathlib.Path('/opt/cyberfinal')/name;p.write_bytes(base64.b64decode(data));p.chmod(0o644)
PY
curl --fail --silent --show-error --retry 4 https://truststore.pki.rds.amazonaws.com/us-east-1/us-east-1-bundle.pem -o /opt/cyberfinal/rds-ca-bundle.pem
chmod 644 /opt/cyberfinal/rds-ca-bundle.pem
python3 - <<'PY'
import json,time,sys,boto3,pymysql
c=json.load(open('/etc/cyberfinal.json')); sm=boto3.client('secretsmanager',region_name=c['region'])
app=json.loads(sm.get_secret_value(SecretId=c['app_secret'])['SecretString'])
# Uma substituição posterior do Web reutiliza o usuário restrito já criado.
try:
    with pymysql.connect(host=c['database_host'],user=app['username'],password=app['password'],database='cyberfinal',connect_timeout=5,ssl={'ca':'/opt/cyberfinal/rds-ca-bundle.pem','check_hostname':True}) as existing:
        with existing.cursor() as cursor: cursor.execute('SELECT id FROM products LIMIT 1')
    sys.exit(0)
except (pymysql.OperationalError,pymysql.ProgrammingError):
    pass
master=json.loads(sm.get_secret_value(SecretId=c['master_secret'])['SecretString'])
for attempt in range(60):
    try:
        db=pymysql.connect(host=c['database_host'],user=master['username'],password=master['password'],database='cyberfinal',connect_timeout=5,ssl={'ca':'/opt/cyberfinal/rds-ca-bundle.pem','check_hostname':True})
        break
    except pymysql.OperationalError:
        if attempt==59: raise RuntimeError('Banco indisponivel para inicializacao') from None
        time.sleep(10)
with db:
    with db.cursor() as cursor:
        cursor.execute('CREATE TABLE IF NOT EXISTS products (id INT PRIMARY KEY, name VARCHAR(120) NOT NULL, price_cents INT NOT NULL)')
        cursor.executemany('INSERT INTO products (id,name,price_cents) VALUES (%s,%s,%s) ON DUPLICATE KEY UPDATE name=VALUES(name),price_cents=VALUES(price_cents)',[(1,'Caderno Horizonte',2490),(2,'Garrafa Aurora',5990),(3,'Mochila Essencial',12990)])
        cursor.execute("CREATE USER IF NOT EXISTS 'catalog_reader'@'%%' IDENTIFIED BY %s REQUIRE SSL",(app['password'],))
        cursor.execute("ALTER USER 'catalog_reader'@'%%' IDENTIFIED BY %s REQUIRE SSL",(app['password'],))
        cursor.execute("GRANT SELECT ON cyberfinal.products TO 'catalog_reader'@'%'")
    db.commit()
# O segredo privilegiado não é salvo em disco. O acesso IAM expira em 2 horas.
del master
PY
cat > /etc/cyberfinal-app.env <<EOF
AWS_DEFAULT_REGION=us-east-1
APP_SECRET_ARN=$APP_SECRET
DB_HOST=$DATABASE_HOST
EOF
chmod 600 /etc/cyberfinal-app.env
cat > /etc/systemd/system/cyberfinal.service <<'EOF'
[Unit]
Description=Catalogo academico Cyber Final
After=network-online.target
Wants=network-online.target
[Service]
User=cyberapp
Group=cyberapp
EnvironmentFile=/etc/cyberfinal-app.env
ExecStart=/usr/bin/python3 /opt/cyberfinal/server.py
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
RestrictSUIDSGID=true
CapabilityBoundingSet=
UMask=0077
[Install]
WantedBy=multi-user.target
EOF
cat > /etc/nginx/sites-available/cyberfinal <<'EOF'
log_format cyberfinal '$remote_addr $request_method $uri $status $body_bytes_sent';
server {
    listen 80 default_server;
    server_name _;
    server_tokens off;
    client_max_body_size 16k;
    access_log /var/log/nginx/access.log cyberfinal;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_hide_header Server;
        proxy_connect_timeout 5s;
        proxy_read_timeout 15s;
    }
}
EOF
ln -sf /etc/nginx/sites-available/cyberfinal /etc/nginx/sites-enabled/cyberfinal
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl daemon-reload
systemctl enable --now cyberfinal
systemctl restart nginx
curl --fail --silent http://127.0.0.1:8080/healthz >/dev/null
touch /var/lib/cyberfinal-role-ready
