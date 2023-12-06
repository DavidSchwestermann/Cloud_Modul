data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_security_group" "ec2" {
  name        = "ec2-allow-ssh-http"
  description = "Security group for the EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
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
  vpc_security_group_ids = [ aws_security_group.sg.id ]
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