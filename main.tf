provider "aws" {
  access_key = var.AWS_Key
  secret_key = var.AWS_Secret
  region     = var.Region_AWS
}

resource "aws_vpc" "VPC010" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-Actividad-10"
  }
}

resource "aws_subnet" "Sub_RedPub01" {
  vpc_id            = aws_vpc.VPC010.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "SubRedPublica_01"
  }
}

resource "aws_subnet" "Sub_RedPub02" {
  vpc_id            = aws_vpc.VPC010.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "SubRedPublica_02"
  }
}

resource "aws_subnet" "Sub_RedPriv01" {
  vpc_id            = aws_vpc.VPC010.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "SubRedPrivada_01"
  }
}

resource "aws_subnet" "Sub_RedPriv02" {
  vpc_id            = aws_vpc.VPC010.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "SubRedPrivada_02"
  }
}

resource "aws_internet_gateway" "InternetGateWay" {
  vpc_id = aws_vpc.VPC010.id
  tags = {
    Name = "InternetGateWay"
  }
}

resource "aws_route_table" "TablaRuteo" {
  vpc_id = aws_vpc.VPC010.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateWay.id
  }
  tags = {
    Name = "Tabla de Ruteo Predeterminada"
  }
}

resource "aws_route_table_association" "AsociacionTRSRPubA" {
  subnet_id      = aws_subnet.Sub_RedPub01.id
  route_table_id = aws_route_table.TablaRuteo.id
}

resource "aws_route_table_association" "AsociacionTRSRPubB" {
  subnet_id      = aws_subnet.Sub_RedPub02.id
  route_table_id = aws_route_table.TablaRuteo.id
}

resource "aws_security_group" "SG-VPC010" {
  vpc_id = aws_vpc.VPC010.id
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
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
    Name = "Permitir_SSH_HTTP_RDP"
  }
}

resource "aws_key_pair" "AWSLLaves" {
  key_name   = "AWSLLaves"
  public_key = file("C:/Users/hecto/.ssh/id_rsa.pub")
}

resource "aws_instance" "InstanciaUbuntu" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Sub_RedPub01.id
  vpc_security_group_ids      = [aws_security_group.SG-VPC010.id]
  key_name                    = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "InstanciaUbuntu"
  }
}

resource "aws_instance" "InstanciaWindows" {
  ami                         = "ami-0324a83b82023f0b3"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.Sub_RedPub02.id
  vpc_security_group_ids      = [aws_security_group.SG-VPC010.id]
  key_name                    = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "InstanciaWindows"
  }
}

output "IPPublicaUbuntu" {
  value       = aws_instance.InstanciaUbuntu.public_ip
  description = "La dirección IP pública de la instancia Ubuntu"
}

output "IPPrivadaUbuntu" {
  value       = aws_instance.InstanciaUbuntu.private_ip
  description = "La dirección IP privada de la instancia Ubuntu"
}

output "IPPublicaWindows" { 
  value       = aws_instance.InstanciaWindows.public_ip
  description = "La dirección IP pública de la instancia Windows"
}

output "IPPrivadaWindows" {
  value       = aws_instance.InstanciaWindows.private_ip
  description = "La dirección IP privada de la instancia Windows"
}

output "IDUbuntu" {
  value       = aws_instance.InstanciaUbuntu.id
  description = "ID de la instancia Ubuntu"
}

output "IDWindows" {
  value       = aws_instance.InstanciaWindows.id
  description = "ID de la instancia Windows"
}