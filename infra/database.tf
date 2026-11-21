resource "random_password" "app" {
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "app" {
  name                    = "${local.name}/app-database"
  recovery_window_in_days = 7
}
resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({ username = "catalog_reader", password = random_password.app.result })
}
resource "aws_db_subnet_group" "lab" {
  name       = local.name
  subnet_ids = aws_subnet.database[*].id
}
resource "aws_db_parameter_group" "lab" {
  name_prefix = "${local.name}-"
  family      = "mysql8.4"
  parameter {
    name  = "require_secure_transport"
    value = "1"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "log_output"
    value = "FILE"
  }
}
resource "aws_db_instance" "lab" {
  identifier                      = local.name
  engine                          = "mysql"
  engine_version                  = "8.4"
  instance_class                  = "db.t4g.micro"
  allocated_storage               = 20
  storage_type                    = "gp3"
  storage_encrypted               = true
  db_name                         = "cyberfinal"
  username                        = "db_bootstrap"
  manage_master_user_password     = true
  db_subnet_group_name            = aws_db_subnet_group.lab.name
  vpc_security_group_ids          = [aws_security_group.database.id]
  parameter_group_name            = aws_db_parameter_group.lab.name
  publicly_accessible             = false
  multi_az                        = false
  backup_retention_period         = 7
  backup_window                   = "06:00-07:00"
  maintenance_window              = "sun:08:00-sun:09:00"
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  auto_minor_version_upgrade      = true
  deletion_protection             = var.protect_database
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${local.name}-final"
  delete_automated_backups        = false
  copy_tags_to_snapshot           = true
}
resource "time_static" "bootstrap" { triggers = { database = aws_db_instance.lab.id } }
