"""Capturas reais da aplicação local em perfil de navegador isolado.

Não são provas do ambiente AWS. O navegador usa somente arquivos deste projeto.
"""
import datetime
import importlib.util
import json
import subprocess
import threading
from pathlib import Path

root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("app_server", root / "app/server.py")
app = importlib.util.module_from_spec(spec)
spec.loader.exec_module(app)
edge = Path("C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")
if not edge.exists():
    raise SystemExit("Microsoft Edge não encontrado; ajuste o caminho antes da captura.")
out = root / "evidencias/locais"
out.mkdir(parents=True, exist_ok=True)
server = app.make_server(port=0, demo=True)
thread = threading.Thread(target=server.serve_forever, daemon=True)
thread.start()
url = f"http://127.0.0.1:{server.server_address[1]}"
captures = []
try:
    # O Edge CLI utiliza largura mínima de layout de 500 px no Windows.
    for name, size in [("desktop", "1440,1100"), ("mobile", "500,2100")]:
        output = out / f"aplicacao-local-{name}.png"
        profile = root / ".local" / f"edge-{name}"
        profile.mkdir(parents=True, exist_ok=True)
        command = [str(edge), "--headless=new", "--disable-gpu", "--disable-extensions", "--no-first-run", "--no-default-browser-check", f"--user-data-dir={profile}", f"--window-size={size}", "--hide-scrollbars", "--virtual-time-budget=3000", f"--screenshot={output}", url]
        subprocess.run(command, capture_output=True, timeout=45, creationflags=subprocess.CREATE_NO_WINDOW, check=True)
        if not output.exists():
            raise RuntimeError("O navegador não produziu a captura esperada.")
        captures.append({"file": output.relative_to(root).as_posix(), "viewport_requested": size, "source": "Microsoft Edge headless", "application_mode": "local demo"})
finally:
    server.shutdown()
    server.server_close()
    thread.join()
(out / "capturas-locais.json").write_text(json.dumps({"collected_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "scope": "aplicação local; sem AWS, VPN, WAF ou MySQL ativo", "captures": captures}, ensure_ascii=False, indent=2), encoding="utf-8", newline="\n")
print(f"Capturas locais registradas: {len(captures)}")
