#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import json,re
c=json.load(open('/etc/cyberfinal.json'))
assert c['role']=='web' and re.fullmatch(r'cyberfinal262-[a-f0-9]{6}',c['project'])
PY
wp eval '
global $wpdb;
$valid=$wpdb->get_row("SHOW STATUS LIKE '\''Ssl_cipher'\''",ARRAY_A);
$bad_ca=mysqli_init();mysqli_ssl_set($bad_ca,null,null,"/etc/ssl/certs/ISRG_Root_X1.pem",null,null);mysqli_options($bad_ca,MYSQLI_OPT_SSL_VERIFY_SERVER_CERT,true);mysqli_options($bad_ca,MYSQLI_OPT_CONNECT_TIMEOUT,5);
$bad_ca_connected=@mysqli_real_connect($bad_ca,DB_HOST,DB_USER,DB_PASSWORD,DB_NAME,3306,null,MYSQLI_CLIENT_SSL);
$bad_host=mysqli_init();mysqli_ssl_set($bad_host,null,null,"/opt/cyberfinal/rds-ca-bundle.pem",null,null);mysqli_options($bad_host,MYSQLI_OPT_SSL_VERIFY_SERVER_CERT,true);mysqli_options($bad_host,MYSQLI_OPT_CONNECT_TIMEOUT,5);
$bad_host_connected=@mysqli_real_connect($bad_host,gethostbyname(DB_HOST),DB_USER,DB_PASSWORD,DB_NAME,3306,null,MYSQLI_CLIENT_SSL);
echo json_encode(["collected_utc"=>gmdate("c"),"wordpress"=>get_bloginfo("version"),"woocommerce"=>WC_VERSION,"php"=>PHP_VERSION,"products"=>(int)wp_count_posts("product")->publish,"db_tls"=>$valid,"db_user"=>$wpdb->get_var("SELECT CURRENT_USER()"),"db_grants"=>$wpdb->get_results("SHOW GRANTS",ARRAY_N),"wrong_ca_connected"=>$bad_ca_connected,"wrong_hostname_connected"=>$bad_host_connected,"file_edits_disabled"=>DISALLOW_FILE_EDIT,"file_mods_disabled"=>DISALLOW_FILE_MODS,"users_can_register"=>get_option("users_can_register"),"mode"=>"catalogo academico sem clientes, pedidos ou pagamentos","site_url"=>home_url("/")],JSON_UNESCAPED_UNICODE);
' --path=/var/www/abcplace --allow-root
echo
wp core verify-checksums --path=/var/www/abcplace --allow-root
wp plugin verify-checksums woocommerce --path=/var/www/abcplace --allow-root
python3 - <<'PY'
import hashlib,json,pathlib,subprocess,urllib.request,urllib.error,datetime
results={}
for path in ['/','/?s=Caderno','/wp-login.php','/wp-admin/','/xmlrpc.php','/wp-config.php','/wp-json/']:
 try:
  with urllib.request.urlopen('http://127.0.0.1'+path,timeout=15) as r:results[path]=r.status
 except urllib.error.HTTPError as e:results[path]=e.code
paths=['wp-content/db.php','wp-content/mu-plugins/academic-catalog.php','wp-content/themes/abcplace/index.php','wp-content/themes/abcplace/style.css']
print(json.dumps({'collected_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'local_http':results,'services':{s:subprocess.run(['systemctl','is-active',s],capture_output=True,text=True).stdout.strip() for s in ['nginx','php8.3-fpm','cyberfinal','wazuh-agent']},'source_sha256':{p:hashlib.sha256((pathlib.Path('/var/www/abcplace')/p).read_bytes()).hexdigest() for p in paths},'claim_boundary':'Sem senha, hash de senha, cookie ou token. Consulta local; bloqueios públicos devem ser confirmados na borda.'},ensure_ascii=False))
PY
