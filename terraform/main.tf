# -------------------------
# Data sources
# -------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# -------------------------
# Networking
# -------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "bookreview-dev-vpc"
  }
}

# Public Subnet A (first AZ)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "bookreview-dev-public-a"
  }
}

# Public Subnet B (second AZ)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "bookreview-dev-public-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "bookreview-dev-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "bookreview-dev-public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "bookreview-dev-sg"
  description = "Allow SSH, frontend, backend, and DB ports"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend app"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend app"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # demo only; restrict in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookreview-dev-sg"
  }
}

# -------------------------
# Compute
# -------------------------
resource "aws_instance" "frontend" {
  ami                    = "ami-08c40ec9ead489470"   # Ubuntu 22.04 LTS x86_64
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  key_name               = "ubuntu-key"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-0c101f26f147fa7fd"   # Amazon Linux 2 x86_64
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_b.id
  key_name               = "ubuntu-key"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "backend"
  }
}

# -------------------------
# Database
# -------------------------
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "mysql-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "mysqladmin"
  password               = "SuperSecret123!"
  db_name                = "bookreviews_dev"
  skip_final_snapshot    = true
  publicly_accessible    = true

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name

  tags = {
    Name = "mysql-db"
  }
}