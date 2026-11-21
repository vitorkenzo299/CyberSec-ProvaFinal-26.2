#!/usr/bin/env bash
# Executar somente no Web novo, com a autorização de teste do laboratório.
set -euo pipefail
python3 - <<'PY'
import json,re
c=json.load(open('/etc/cyberfinal.json'))
assert c['role']=='web' and re.fullmatch(r'cyberfinal262-[a-f0-9]{6}',c['project']), 'Host fora do escopo'
PY
target=/opt/cyberfinal/evidence-probe.txt
test ! -e "$target"
printf 'Arquivo benigno de teste FIM\n' > "$target"
date -u; echo FIM_CREATED
sleep 12
printf 'Alteracao controlada\n' >> "$target"
date -u; echo FIM_MODIFIED
sleep 12
rm -- "$target"
date -u; echo FIM_DELETED
