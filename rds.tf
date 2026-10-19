# ---------------------------------------------------------------------------
# Database (private database subnets)
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  # RDS generates the password and stores it in AWS Secrets Manager,
  # so no password ever appears in the Terraform code or state file.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  backup_retention_period = 7
  multi_az                = false # set true for production high availability

  # Lab settings so `terraform destroy` works cleanly.
  # For production: skip_final_snapshot = false and deletion_protection = true
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "${var.project_name}-db" }
}
