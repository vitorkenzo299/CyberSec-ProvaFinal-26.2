#!/usr/bin/env bash
set -euo pipefail
python3 - <<'VERIFY_HOST'
import json,re
c=json.load(open('/etc/cyberfinal.json'))
assert c['role']=='wazuh' and re.fullmatch(r'cyberfinal262-[a-f0-9]{6}',c['project']), 'Host fora do escopo'
VERIFY_HOST
apt-get -o DPkg::Lock::Timeout=300 install -y python3-yaml >/dev/null
python3 - <<'PY'
import base64,json,pathlib,secrets,ssl,urllib.request,urllib.error,yaml
p=pathlib.Path('/root/cyberfinal-viewer.json')
viewer=json.loads(p.read_text()) if p.exists() else {'username':'vitor','password':secrets.token_urlsafe(28)+'aA1!'}
p.write_text(json.dumps(viewer));p.chmod(0o600)
ctx=ssl.create_default_context(cafile='/etc/wazuh-indexer/certs/root-ca.pem');ctx.check_hostname=False
ctx.load_cert_chain('/etc/wazuh-indexer/certs/admin.pem','/etc/wazuh-indexer/certs/admin-key.pem')
def call(base,path,method='GET',data=None,headers=None,context=ctx):
    req=urllib.request.Request(base+path,data=json.dumps(data).encode() if data is not None else None,method=method,headers={'Content-Type':'application/json',**(headers or {})})
    with urllib.request.urlopen(req,context=context,timeout=60) as r:
        raw=r.read().decode();return json.loads(raw) if raw and raw[0] in '[{' else raw
idx='https://127.0.0.1:9200'
call(idx,'/_plugins/_security/api/internalusers/vitor','PUT',{'password':viewer['password'],'backend_roles':['cyberfinal_observer'],'attributes':{'purpose':'avaliacao-final-leitura'}})
call(idx,'/_plugins/_security/api/roles/cyberfinal_readonly','PUT',{'cluster_permissions':['cluster_composite_ops_ro'],'index_permissions':[{'index_patterns':['*'],'allowed_actions':['read']}],'tenant_permissions':[{'tenant_patterns':['global_tenant'],'allowed_actions':['kibana_all_read']}]})
call(idx,'/_plugins/_security/api/rolesmapping/cyberfinal_readonly','PUT',{'users':['vitor'],'backend_roles':['cyberfinal_observer']})
cfgpath=pathlib.Path('/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml')
cfg=yaml.safe_load(cfgpath.read_text());host=next(iter(cfg['hosts'][0].values()))
api='https://127.0.0.1:55000';localctx=ssl._create_unverified_context()
basic=base64.b64encode((host['username']+':'+host['password']).encode()).decode()
token=call(api,'/security/user/authenticate?raw=true','POST',headers={'Authorization':'Basic '+basic},context=localctx)
hdr={'Authorization':'Bearer '+token}
roles=call(api,'/security/roles',headers=hdr,context=localctx)['data']['affected_items']
role=next(r for r in roles if r['name']=='readonly')
rules=call(api,'/security/rules',headers=hdr,context=localctx)['data']['affected_items']
rule=next((r for r in rules if r['name']=='cyberfinal_vitor_readonly'),None)
if not rule:
    rule=call(api,'/security/rules','POST',{'name':'cyberfinal_vitor_readonly','rule':{'FIND':{'user_name':'vitor'}}},hdr,localctx)['data']['affected_items'][0]
call(api,'/security/roles/'+str(role['id'])+'/rules?rule_ids='+str(rule['id']),'POST',headers=hdr,context=localctx)
host['run_as']=True;cfgpath.write_text(yaml.safe_dump(cfg,sort_keys=False))
print(json.dumps({'user':'vitor','credential_file':'/root/cyberfinal-viewer.json','role':'cyberfinal_readonly','wazuh_role':role['name'],'agents':call(api,'/agents?select=id,name,status,version',headers=hdr,context=localctx)['data']}))
PY
systemctl restart wazuh-dashboard
