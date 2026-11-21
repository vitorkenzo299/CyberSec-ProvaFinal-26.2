import importlib.util
import json
import threading
import unittest
from unittest.mock import MagicMock, patch
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import urlopen

spec = importlib.util.spec_from_file_location("server", Path(__file__).parents[1] / "app/server.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class CatalogHttpTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = module.make_server(port=0, demo=True)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = "http://127.0.0.1:" + str(cls.server.server_address[1])

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def test_catalog_and_search(self):
        with urlopen(self.url + "/api/products?search=Caderno") as response:
            products = json.load(response)["products"]
        self.assertEqual([p["id"] for p in products], [1])

    def test_injection_payload_is_plain_search_input(self):
        with urlopen(self.url + "/api/products?search=%27%20OR%201%3D1--") as response:
            self.assertEqual(json.load(response)["products"], [])

    def test_mysql_path_keeps_sql_and_user_input_separate(self):
        sdk = MagicMock()
        sdk.client.return_value.get_secret_value.return_value = {"SecretString": json.dumps({"username": "catalog_reader", "password": "fake-unit-test-value"})}
        mysql = MagicMock()
        cursor = mysql.connect.return_value.__enter__.return_value.cursor.return_value.__enter__.return_value
        cursor.fetchall.return_value = []
        payload = "' OR 1=1--"
        with patch.dict("sys.modules", {"boto3": sdk, "pymysql": mysql}), patch.dict("os.environ", {"APP_SECRET_ARN": "unit-test", "DB_HOST": "database.test"}):
            module.Catalog(demo=False).products(payload)
        query, parameters = cursor.execute.call_args.args
        self.assertNotIn(payload, query)
        self.assertEqual(parameters, ("%" + payload + "%",))
        self.assertEqual(mysql.connect.call_args.kwargs["ssl"]["check_hostname"], True)

    def test_failure_does_not_expose_internal_details(self):
        previous = self.server.catalog
        class BrokenCatalog:
            def products(self, search):
                raise RuntimeError("sensitive-value-must-not-appear")
        self.server.catalog = BrokenCatalog()
        try:
            with self.assertLogs(level="ERROR") as logs, self.assertRaises(HTTPError) as ctx:
                urlopen(self.url + "/api/products")
            self.assertEqual(ctx.exception.code, 503)
            self.assertNotIn(b"sensitive-value", ctx.exception.read())
            self.assertNotIn("sensitive-value", " ".join(logs.output))
        finally:
            self.server.catalog = previous

    def test_response_security_headers(self):
        with urlopen(self.url + "/") as response:
            self.assertEqual(response.headers["X-Content-Type-Options"], "nosniff")
            self.assertIn("frame-ancestors 'none'", response.headers["Content-Security-Policy"])

    def test_path_traversal_does_not_serve_files(self):
        with self.assertRaises(HTTPError) as ctx:
            urlopen(self.url + "/../server.py")
        self.assertEqual(ctx.exception.code, 404)


if __name__ == "__main__":
    unittest.main()
