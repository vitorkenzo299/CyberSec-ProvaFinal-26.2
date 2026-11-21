"""Loja acadêmica com catálogo sintético e consultas parametrizadas.

Local: python app/server.py --demo. AWS: MySQL privado, TLS verificado e
credencial recuperada do Secrets Manager pela identidade da instância.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

ROOT = Path(__file__).resolve().parent
PRODUCTS = [
    {"id": 1, "name": "Caderno Horizonte", "price_cents": 2490},
    {"id": 2, "name": "Garrafa Aurora", "price_cents": 5990},
    {"id": 3, "name": "Mochila Essencial", "price_cents": 12990},
]


class Catalog:
    def __init__(self, demo: bool = False):
        self.demo = demo

    def products(self, search: str = "") -> list[dict]:
        if self.demo:
            return [p.copy() for p in PRODUCTS if search.casefold() in p["name"].casefold()]
        import boto3
        import pymysql

        # Não manter senha em variável de ambiente, arquivo de configuração ou log.
        secret = json.loads(boto3.client("secretsmanager").get_secret_value(
            SecretId=os.environ["APP_SECRET_ARN"])["SecretString"])
        with pymysql.connect(
            host=os.environ["DB_HOST"], user=secret["username"], password=secret["password"],
            database="cyberfinal", connect_timeout=5, read_timeout=5,
            ssl={"ca": "/opt/cyberfinal/rds-ca-bundle.pem", "check_hostname": True},
            cursorclass=pymysql.cursors.DictCursor,
        ) as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT id, name, price_cents FROM products WHERE name LIKE %s ORDER BY id LIMIT 50",
                    ("%" + search + "%",),
                )
                return list(cursor.fetchall())


class Handler(BaseHTTPRequestHandler):
    server_version = "CyberFinal"
    sys_version = ""

    def respond(self, status: int, body: bytes, content_type: str):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
        self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'")
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def json(self, status: int, data):
        self.respond(status, json.dumps(data, ensure_ascii=False).encode(), "application/json; charset=utf-8")

    def do_GET(self):
        parsed = urlsplit(self.path)
        if len(self.path) > 2048:
            return self.json(HTTPStatus.REQUEST_URI_TOO_LONG, {"error": "Requisição longa demais"})
        if parsed.path in ("/healthz", "/api/products"):
            query = parse_qs(parsed.query)
            search = query.get("search", [""])[0]
            if len(search) > 120:
                return self.json(HTTPStatus.BAD_REQUEST, {"error": "Busca limitada a 120 caracteres"})
            try:
                products = self.server.catalog.products(search)
                if parsed.path == "/healthz":
                    return self.json(HTTPStatus.OK, {"status": "ok", "catalog": "available", "mode": "demo" if self.server.catalog.demo else "mysql"})
                return self.json(HTTPStatus.OK, {"products": products})
            except Exception:
                logging.error("catalog_unavailable")
                return self.json(HTTPStatus.SERVICE_UNAVAILABLE, {"error": "Catálogo temporariamente indisponível"})
        static = {"/": ("index.html", "text/html"), "/style.css": ("style.css", "text/css"), "/app.js": ("app.js", "text/javascript")}
        if parsed.path in static:
            filename, content_type = static[parsed.path]
            return self.respond(HTTPStatus.OK, (ROOT / filename).read_bytes(), content_type + "; charset=utf-8")
        return self.json(HTTPStatus.NOT_FOUND, {"error": "Recurso não encontrado"})

    do_HEAD = do_GET

    def log_message(self, format, *args):
        # Não registrar query strings, tokens, cookies ou cabeçalhos do cliente.
        logging.info("request method=%s path=%s", getattr(self, "command", ""), urlsplit(getattr(self, "path", "")).path[:160])


def make_server(host="127.0.0.1", port=8080, demo=False):
    server = ThreadingHTTPServer((host, port), Handler)
    server.catalog = Catalog(demo=demo)
    return server


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--demo", action="store_true")
    parser.add_argument("--port", type=int, default=8080)
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
    make_server(port=args.port, demo=args.demo).serve_forever()
