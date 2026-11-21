"""Executa verificações locais e registra seus resultados reais."""
import argparse
import datetime
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--terraform", default="terraform")
args = parser.parse_args()
checks = [
    ("application_tests", [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"]),
    ("terraform_format", [args.terraform, "-chdir=infra", "fmt", "-check", "-recursive", "-no-color"]),
    ("terraform_validate", [args.terraform, "-chdir=infra", "validate", "-no-color"]),
    ("terraform_mock_test", [args.terraform, "-chdir=infra", "test", "-no-color"]),
]
node = shutil.which("node")
if node:
    checks.append(("javascript_syntax", [node, "--check", "app/app.js"]))
bash = shutil.which("bash")
windows_bash = Path("C:/Program Files/Git/bin/bash.exe")
if windows_bash.exists():
    bash = str(windows_bash)
if bash:
    for file in sorted((root / "infra/scripts").glob("*.sh")):
        checks.append(("shell_syntax_" + file.stem, [bash, "-n", file.relative_to(root).as_posix()]))
results = []
for name, command in checks:
    started = time.monotonic()
    result = subprocess.run(command, cwd=root, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=180)
    results.append({"check": name, "exit_code": result.returncode, "seconds": round(time.monotonic() - started, 3), "stdout": result.stdout, "stderr": result.stderr})
    print(name + ": " + ("PASS" if result.returncode == 0 else "FAIL"))
out = root / "evidencias/locais/validacao-local.json"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps({"collected_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "scope": "testes locais e provedores simulados; nenhum recurso AWS criado", "all_passed": all(r["exit_code"] == 0 for r in results), "results": results}, ensure_ascii=False, indent=2), encoding="utf-8", newline="\n")
raise SystemExit(0 if all(r["exit_code"] == 0 for r in results) else 1)
