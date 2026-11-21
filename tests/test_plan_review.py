import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("review_plan", Path(__file__).parents[1] / "scripts/review_plan.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PlanReviewTests(unittest.TestCase):
    def plan(self, actions, funded=True, account="111122223333"):
        return {"variables": {"expected_account_id": {"value": account}, "funding_source_confirmed": {"value": funded}}, "resource_changes": [{"address": "aws_instance.example", "change": {"actions": actions}}]}

    def test_accepts_new_resources_in_the_verified_account(self):
        self.assertTrue(module.review(self.plan(["create"]), "111122223333")["approved_structure"])

    def test_rejects_modification_deletion_and_replacement(self):
        for actions in (["update"], ["delete"], ["delete", "create"], ["create", "delete"]):
            with self.subTest(actions=actions):
                self.assertFalse(module.review(self.plan(actions), "111122223333")["approved_structure"])

    def test_rejects_unknown_funding_or_another_account(self):
        self.assertFalse(module.review(self.plan(["create"], funded=False), "111122223333")["approved_structure"])
        self.assertFalse(module.review(self.plan(["create"]), "000000000000")["approved_structure"])
