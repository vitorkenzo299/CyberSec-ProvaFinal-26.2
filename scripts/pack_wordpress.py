"""Empacota somente fontes públicas para a pós-instalação WordPress no Web novo."""
import argparse
import base64
import json
from pathlib import Path

root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--output',required=True,type=Path)
args=parser.parse_args()
payload={}
for path in sorted((root/'wordpress').rglob('*')):
    if path.is_file():
        name=path.relative_to(root/'wordpress').as_posix().replace('theme/','themes/abcplace/',1)
        payload[name]=base64.b64encode(path.read_bytes()).decode()
body='export WORDPRESS_SOURCE_B64='+base64.b64encode(json.dumps(payload).encode()).decode()+'\n'+(root/'infra/scripts/install-wordpress.sh').read_text(encoding='utf-8')
args.output.parent.mkdir(parents=True,exist_ok=True)
args.output.write_text(body,encoding='utf-8',newline='\n')
print('Fontes públicas empacotadas. O arquivo não contém senha, chave ou token.')
