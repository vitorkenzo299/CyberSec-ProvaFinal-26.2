"""Coleta somente recursos identificados pelos outputs deste laboratório novo.

Pré-requisitos: boto3 e arquivo privado com terraform output -json.
Não lê senhas, conteúdo de Secrets Manager ou perfis VPN.
"""
import argparse
import datetime
import json
import re
from pathlib import Path

import boto3

parser = argparse.ArgumentParser()
parser.add_argument("--outputs", type=Path, required=True)
parser.add_argument("--account", required=True)
args = parser.parse_args()
if not re.fullmatch(r"\d{12}", args.account):
    parser.error("Informe os 12 dígitos da conta escolhida.")
values = json.loads(args.outputs.read_text(encoding="utf-8-sig"))
values = {key: item["value"] for key, item in values.items()}
project = values["project_name"]
if not re.fullmatch(r"[a-z][a-z0-9-]{2,30}", project):
    raise SystemExit("Prefixo de projeto inválido.")
session = boto3.Session(region_name="us-east-1")
identity = session.client("sts").get_caller_identity()
if identity["Account"] != args.account or identity["Arn"].endswith(":root") or re.search(r":user/(?:root|admin)$", identity["Arn"], re.IGNORECASE):
    raise SystemExit("A identidade atual não corresponde à conta nominal escolhida.")
ids = list(values["instance_ids"].values())
if len(ids) != 3 or not all(re.fullmatch(r"i-[a-f0-9]+", item) for item in ids):
    raise SystemExit("Esperadas as três instâncias deste projeto.")
ec2 = session.client("ec2")
instances = [item for reservation in ec2.describe_instances(InstanceIds=ids)["Reservations"] for item in reservation["Instances"]]
for item in instances:
    tags = {tag["Key"]: tag["Value"] for tag in item.get("Tags", [])}
    if tags.get("Project") != project or item["VpcId"] != values["vpc_id"]:
        raise SystemExit("Recurso fora do projeto; coleta interrompida.")
if set(item["InstanceId"] for item in instances) != set(ids):
    raise SystemExit("Inventário incompleto; coleta interrompida.")
now = datetime.datetime.now(datetime.timezone.utc)
out = Path(__file__).resolve().parents[1] / "evidencias/atuais" / now.strftime("%Y%m%dT%H%M%SZ")
out.mkdir(parents=True, exist_ok=False)


def save(name, data):
    text = json.dumps({"collected_utc": now.isoformat(), "project": project, "data": data}, ensure_ascii=False, indent=2, default=str)
    text = text.replace(args.account, "AWS_ACCOUNT")
    (out / name).write_text(text, encoding="utf-8", newline="\n")


save("collection-status.json", {"complete": False})
save("identidade.json", {key: identity[key] for key in ("Account", "Arn")})
save("instancias.json", [{key: item.get(key) for key in ("InstanceId", "InstanceType", "State", "PrivateIpAddress", "PublicIpAddress", "SubnetId", "VpcId", "SecurityGroups", "MetadataOptions", "IamInstanceProfile", "Tags")} for item in instances])
db_id = values["database_identifier"]
if db_id != project:
    raise SystemExit("Banco fora do projeto.")
db = session.client("rds").describe_db_instances(DBInstanceIdentifier=db_id)["DBInstances"][0]
db_tags = session.client("rds").list_tags_for_resource(ResourceName=db["DBInstanceArn"])["TagList"]
if {tag["Key"]: tag["Value"] for tag in db_tags}.get("Project") != project:
    raise SystemExit("Tag do banco não corresponde ao projeto.")
save("banco.json", {key: db.get(key) for key in ("DBInstanceIdentifier", "DBInstanceStatus", "DBInstanceClass", "Engine", "EngineVersion", "PubliclyAccessible", "StorageEncrypted", "BackupRetentionPeriod", "LatestRestorableTime", "DeletionProtection", "MultiAZ", "VpcSecurityGroups", "DBSubnetGroup", "EnabledCloudwatchLogsExports")})
groups = {group["GroupId"] for item in instances for group in item["SecurityGroups"]}
groups.update(group["VpcSecurityGroupId"] for group in db["VpcSecurityGroups"])
save("security-groups.json", ec2.describe_security_groups(GroupIds=sorted(groups))["SecurityGroups"])
save("sub-redes.json", ec2.describe_subnets(Filters=[{"Name": "vpc-id", "Values": [values["vpc_id"]]}])["Subnets"])
save("rotas.json", ec2.describe_route_tables(Filters=[{"Name": "vpc-id", "Values": [values["vpc_id"]]}])["RouteTables"])
waf = session.client("wafv2").get_web_acl(Name=project, Scope="CLOUDFRONT", Id=values["web_acl_id"])["WebACL"]
save("waf-configuracao.json", waf)
cf = session.client("cloudfront").get_distribution_config(Id=values["cloudfront_distribution_id"])["DistributionConfig"]
if cf.get("WebACLId") != waf["ARN"]:
    raise SystemExit("CloudFront não está associado ao WAF esperado.")
save("cloudfront.json", {key: cf.get(key) for key in ("Enabled", "WebACLId", "Origins", "ViewerCertificate", "Aliases", "DefaultCacheBehavior")})
save("alarmes.json", session.client("cloudwatch").describe_alarms(AlarmNamePrefix=project)["MetricAlarms"])
save("auditoria-status.json", session.client("cloudtrail").get_trail_status(Name=project))
save("collection-status.json", {"complete": True})
print(json.dumps({"output": str(out), "files": len(list(out.glob('*.json')))}, ensure_ascii=False))
