"""Recusa alterações e exclusões no plano inicial de uma conta compartilhada."""
import argparse
import json
from pathlib import Path


def review(plan: dict, expected_account: str) -> dict:
    variables = plan.get("variables", {})
    actual_account = variables.get("expected_account_id", {}).get("value")
    funding = variables.get("funding_source_confirmed", {}).get("value") is True
    errors = []
    if actual_account != expected_account:
        errors.append("A conta do plano não corresponde à conta escolhida.")
    if not funding:
        errors.append("A cobertura acadêmica sem desembolso pessoal não foi confirmada.")
    counts = {"create": 0, "read": 0, "no-op": 0}
    for resource in plan.get("resource_changes", []):
        actions = resource.get("change", {}).get("actions", [])
        if len(actions) != 1 or actions[0] not in counts:
            errors.append("Alteração não permitida: " + resource.get("address", "desconhecido") + " (" + ",".join(actions) + ")")
        else:
            counts[actions[0]] += 1
    if plan.get("errored"):
        errors.append("O Terraform registrou erro ao preparar o plano.")
    if plan.get("applyable") is False:
        errors.append("O plano não está aplicável.")
    return {"approved_structure": not errors, "actions": counts, "errors": errors, "scope": "Estrutura do plano; não confirma créditos, cotação nem permissões efetivas."}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan-json", type=Path, required=True)
    parser.add_argument("--account", required=True)
    args = parser.parse_args()
    result = review(json.loads(args.plan_json.read_text(encoding="utf-8-sig")), args.account)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(0 if result["approved_structure"] else 1)
