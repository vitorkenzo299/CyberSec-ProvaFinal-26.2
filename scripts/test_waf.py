"""Quatro requisições controladas ao domínio deste laboratório, sem carga de DoS."""
import argparse
import datetime
import json
import ssl
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("url")
parser.add_argument("--out", default="evidencias/atuais/waf-test.json")
args = parser.parse_args()
url = urllib.parse.urlsplit(args.url)
if url.scheme != "https" or not url.hostname or url.username or url.password or url.port not in (None, 443) or url.query or url.fragment or url.path not in ("", "/"):
    parser.error("Informe a origem HTTPS do novo laboratório, sem caminho ou credenciais.")
run_id = str(uuid.uuid4())
tests = [
    ("catalog_health", "/healthz", {}, 200),
    ("controlled_waf_probe", "/healthz", {"x-cyberfinal-test": "blocked"}, 403),
    ("sqli_signature_observation", "/api/products?search=" + urllib.parse.quote("' OR 1=1--"), {}, None),
    ("legitimate_catalog_after", "/api/products", {}, 200),
]
results = []
for name, path, extra, expected in tests:
    record = {"name": name, "path": path, "expected_status": expected}
    request = urllib.request.Request(args.url.rstrip("/") + path, headers={"User-Agent": "CyberFinal-Evidence/1.0", "x-cyberfinal-evidence": run_id, **extra})
    try:
        try:
            response = urllib.request.urlopen(request, timeout=20, context=ssl.create_default_context())
        except urllib.error.HTTPError as error:
            response = error
        with response:
            record.update(status=response.code, final_url=response.geturl(), headers={key: value for key, value in response.headers.items() if key.lower() in {"date", "server", "x-cache", "x-amz-cf-id", "strict-transport-security", "content-type"}})
            # Nenhum corpo é publicado: pode conter informação da aplicação.
            response.read(1024)
        record["passed"] = expected is None or record["status"] == expected
    except Exception as error:
        record.update(passed=False, error_type=type(error).__name__)
    results.append(record)
data = {"collected_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "run_id": run_id, "scope": "quatro requisições ao domínio informado; não substitui varredura de vulnerabilidades", "certificate_validation": True, "results": results}
out = Path(args.out)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8", newline="\n")
print(json.dumps({"output": str(out), "passed": all(r["passed"] for r in results)}, ensure_ascii=False))
raise SystemExit(0 if all(r["passed"] for r in results) else 1)
