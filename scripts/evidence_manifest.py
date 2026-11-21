"""Registra tamanho e SHA-256 das evidências existentes, sem fabricar resultados."""
import datetime
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
evidence = root / "evidencias"
out = evidence / "manifesto.json"
files = []
for file in sorted(evidence.rglob("*")):
    if not file.is_file() or file == out:
        continue
    files.append({"path": file.relative_to(root).as_posix(), "bytes": file.stat().st_size, "sha256": hashlib.sha256(file.read_bytes()).hexdigest()})
out.write_text(json.dumps({"generated_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "files": files}, ensure_ascii=False, indent=2), encoding="utf-8", newline="\n")
print(f"Manifesto atualizado: {len(files)} arquivos.")
