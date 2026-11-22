#!/usr/bin/env bash
# Medidas compensatórias autorizadas para os três hosts novos; não substituem patches.
set -euo pipefail
python3 - <<'PY'
import datetime,json,pathlib,subprocess
c=json.load(open('/etc/cyberfinal.json'))
assert c['project']=='cyberfinal262-5f48e9' and c['role'] in ['web','vpn','wazuh']
modules=['xen_netback','sch_teql','cifs','ksmbd','ntfs3','libertas','amdgpu','binder_linux','algif_skcipher','algif_aead','sctp','rds','tipc','can','smc','siw','rdma_ucm','libiscsi','iscsi_tcp','bluetooth','btusb','rfcomm','bnep']
loaded={line.split()[0] for line in pathlib.Path('/proc/modules').read_text().splitlines()}
assert not (set(modules)&loaded),'Revisar módulos em uso sem descarregar: '+str(set(modules)&loaded)
keys=['kernel.io_uring_disabled','kernel.kptr_restrict']
before={k:subprocess.check_output(['sysctl','-n',k],text=True).strip() for k in keys}
backup=pathlib.Path('/root/abcplace-kernel-before.json')
if not backup.exists():backup.write_text(json.dumps(before));backup.chmod(0o600)
p=pathlib.Path('/etc/modprobe.d/abcplace-unused-modules.conf')
p.write_text('# Recursos sem uso na loja, VPN e SIEM; arquivos dos módulos preservados.\n'+''.join('blacklist '+m+'\ninstall '+m+' /bin/false\n' for m in modules));p.chmod(0o644)
settings={'kernel.io_uring_disabled':'2','kernel.kptr_restrict':'2'}
p=pathlib.Path('/etc/sysctl.d/99-abcplace-kernel.conf');p.write_text('\n'.join(k+' = '+v for k,v in settings.items())+'\n');p.chmod(0o644)
subprocess.run(['sysctl','-p',str(p)],check=True,capture_output=True)
after={k:subprocess.check_output(['sysctl','-n',k],text=True).strip() for k in keys};assert after==settings
checks={}
for m in modules:
 r=subprocess.run(['modprobe','-n','-v',m],capture_output=True,text=True)
 auto=subprocess.run(['modprobe','--use-blacklist','-n','-v',m],capture_output=True,text=True)
 checks[m]={'loaded':m in loaded,'manual_dry_run':r.stdout.strip(),'autoload_dry_run':auto.stdout.strip(),'autoload_returncode':auto.returncode}
 assert auto.returncode==0 and not auto.stdout.strip(),'Carga automática não bloqueada: '+m
services={'web':['nginx','php8.3-fpm','cyberfinal','wazuh-agent','amazon-cloudwatch-agent'],'vpn':['openvpn-server@server','wazuh-agent','amazon-cloudwatch-agent'],'wazuh':['wazuh-manager','wazuh-indexer','wazuh-dashboard','amazon-cloudwatch-agent']}[c['role']]
status={s:subprocess.check_output(['systemctl','is-active',s],text=True).strip() for s in services};assert all(x=='active' for x in status.values())
print(json.dumps({'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'role':c['role'],'kernel':subprocess.check_output(['uname','-r'],text=True).strip(),'sysctl_saved_baseline':json.loads(backup.read_text()),'sysctl_after':after,'modules':checks,'services':status,'boundary':'Carga automática bloqueada. Um administrador root ainda pode alterar a política ou carregar módulos explicitamente; softdeps podem sobrepor install em modprobe manual. Não apaga arquivos/alertas nem equivale a patches.'},ensure_ascii=False))
PY
