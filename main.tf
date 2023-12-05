# Initialisierunge
module "rds" {
source = "./rds"
rdsusername = var.rdsusername
rdspasswd = var.rdspasswd
# rdsdbname = var.rdsdbname
}

# Setzten von Variabeln
variable "rdspasswd" {}
variable "rdsusername" {}
# variable "rdsdbname" {}

# AWS Login über IAM
provider "aws" {
  region                  = "us-west-2"
  profile                 = "akhil"
}

# Using Default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "David VPC Default"
  }
}

# Creating a Security Group for our DB Instance
resource "aws_security_group" "sg" {
  name        = "db-david"
  description = "Allow Database inbound traffic"
  vpc_id      = aws_default_vpc.default.id
ingress {
    description = "MYSQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
  tags = {
    Name = "sg-for-db"
  }
}

# Creating DB Instance in RDS 
resource "aws_db_instance" "default" {
  identifier           = "wpdatabase"
  engine               = "mysql"
  engine_version       = "5.7.21"
  name                 = "mysqldb"
  username             = var.rdsusername
  password             = var.rdspasswd
  allocated_storage    = 20
  max_allocated_storage = 25
  storage_type         = "gp2"
  availability_zone    = "ap-south-1b"
  instance_class       = "db.t2.micro"
  port                 = 3306
  publicly_accessible  = true
  skip_final_snapshot = true
  vpc_security_group_ids = [ "${aws_security_group.sg.id}" ]
  tags = {
    Name = "awsrds"
  }
    depends_on = [
    aws_security_group.sg,
  ]
}

#WORDPRESS_DB_HOST (Database Host)
output "rds_dbhost" {
    value = aws_db_instance.default.endpoint
}

#WORDPRESS_DB_NAME(Database Name)
output "rds_dbname" {
    value = aws_db_instance.default.name
}

# Creating a Local file, which contains details of our Login Details #in Wordpress
resource "local_file" "credentials" {
    content = "WORDPRESS_DB_HOST => ${aws_db_instance.default.endpoint}\n WORDPRESS_DB_USER ${aws_db_instance.default.username}\n WORDPRESS_DB_PASSWORD ${aws_db_instance.default.password}\n WORDPRESS_DB_NAME ${aws_db_instance.default.name}"
    filename = "details"
}