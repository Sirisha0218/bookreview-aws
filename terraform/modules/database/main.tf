# Security group for MySQL
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Allow MySQL access from backend EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.backend_sg_id]   # allow from backend SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL instance
resource "aws_db_instance" "mysql" {
  identifier              = "bookreview-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"              # 5.7 is deprecated
  instance_class          = "db.t4g.micro"
  username                = var.mysql_admin_username
  password                = var.mysql_admin_password
  db_name                 = var.mysql_database_name
  publicly_accessible     = true
  skip_final_snapshot     = true
  deletion_protection     = false
  vpc_security_group_ids  = [aws_security_group.mysql_sg.id]
}
