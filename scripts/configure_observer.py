"""Cria a função de consulta pós-provisionamento, somente no projeto dos outputs.

Exige uma sessão nominal autorizada para criar IAM. Não exporta credenciais.
"""
import argparse
import json
from pathlib import Path

import boto3

parser = argparse.ArgumentParser()
parser.add_argument("--outputs", required=True, type=Path)
parser.add_argument("--account", required=True)
args = parser.parse_args()
values = {key: value["value"] for key, value in json.loads(args.outputs.read_text(encoding="utf-8-sig")).items()}
project = values["project_name"]
if not project.startswith("cyberfinal262-") or len(project) != 20:
    raise SystemExit("Projeto diferente desta avaliação.")
session = boto3.Session(region_name="us-east-1")
identity = session.client("sts").get_caller_identity()
if identity["Account"] != args.account or ":assumed-role/" not in identity["Arn"]:
    raise SystemExit("Use a sessão nominal assumida da conta indicada.")
iam = session.client("iam")
source = iam.get_role(RoleName=identity["Arn"].split("/")[-2])["Role"]["Arn"]
name = project + "-observer"
trust = {"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"AWS": source}, "Action": "sts:AssumeRole", "Condition": {"StringLike": {"sts:RoleSessionName": "vitor-consulta-*"}}}]}
try:
    role = iam.get_role(RoleName=name)["Role"]
except iam.exceptions.NoSuchEntityException:
    role = iam.create_role(RoleName=name, AssumeRolePolicyDocument=json.dumps(trust), Description="Consulta da avaliacao final; sem acoes de alteracao", Tags=[{"Key": "Project", "Value": project}, {"Key": "Role", "Value": "observer"}])["Role"]
if {t["Key"]: t["Value"] for t in role.get("Tags", [])}.get("Project") != project:
    raise SystemExit("A função existente não pertence ao laboratório; interrompido.")
policy = {"Version": "2012-10-17", "Statement": [
    {"Sid": "InventoryReadOnly", "Effect": "Allow", "Action": ["ec2:Describe*", "rds:Describe*", "cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*", "wafv2:Get*", "wafv2:List*", "cloudfront:Get*", "cloudfront:List*", "cloudtrail:GetTrailStatus", "cloudtrail:DescribeTrails", "cloudtrail:ListTrails", "cloudtrail:LookupEvents", "logs:Describe*"], "Resource": "*"},
    {"Sid": "LabLogsRead", "Effect": "Allow", "Action": ["logs:GetLogEvents", "logs:FilterLogEvents"], "Resource": [f"arn:aws:logs:us-east-1:{args.account}:log-group:/{project}/*:*", f"arn:aws:logs:us-east-1:{args.account}:log-group:aws-waf-logs-{project}:*"]},
    {"Sid": "TrailConfigurationRead", "Effect": "Allow", "Action": ["cloudtrail:GetTrail", "cloudtrail:GetEventSelectors", "cloudtrail:GetInsightSelectors", "cloudtrail:ListTags"], "Resource": f"arn:aws:cloudtrail:us-east-1:{args.account}:trail/{project}"},
]}
iam.put_role_policy(RoleName=name, PolicyName="LabReadOnly", PolicyDocument=json.dumps(policy))
print(json.dumps({"role": name, "credential_exported": False, "terraform_managed": False}))
