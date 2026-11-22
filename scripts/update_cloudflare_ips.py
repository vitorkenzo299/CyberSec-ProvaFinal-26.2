"""Atualiza somente a lista local oficial; implantação exige revisão do plano."""
import datetime,hashlib,ipaddress,json,urllib.request
from pathlib import Path
root=Path(__file__).resolve().parents[1];d={'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source':'https://api.cloudflare.com/client/v4/ips'}
request=urllib.request.Request(d['source'],headers={'User-Agent':'ABCPlace-assessment/1.0'})
with urllib.request.urlopen(request,timeout=20) as r:raw=r.read()
payload=json.loads(raw);assert payload['success'];d['response_sha256']=hashlib.sha256(raw).hexdigest()
for version in [4,6]:
 ranges=payload['result']['ipv'+str(version)+'_cidrs']
 assert ranges and all(ipaddress.ip_network(x).version==version and ipaddress.ip_network(x).is_global for x in ranges)
 d['ipv'+str(version)]=ranges
(root/'infra/cloudflare-ips.json').write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print(json.dumps({'ipv4_count':len(d['ipv4']),'ipv6_count':len(d['ipv6'])}))
