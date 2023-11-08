provider "aws" {
}

#This is VPC code

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
}

#This is Subnet code

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "Public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Private-subnet"
  }
}

#security group

resource "aws_security_group" "test_access" {
  name        = "test_access"
  description = "allow ssh and http"
  vpc_id = aws_vpc.test-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#internet gateway code

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-igw"
  }
}

#Public route table code

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

#route Tatable assosication code

resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

#ssh keypair code

resource "aws_key_pair" "ltimindtreekey" {
  key_name   = "ltimindtreekey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkTVe/d89MGn2Gwb4fAqa0ajQANyyIANG4dnX7wDzLe1nPClHaerr0TFLxgo+tvMew1c3Efso0yCukF7udvhYS+G7jmPOqBd7q8/85m7iuEJE3fT6hKlKPNqm4EjaPPhgVDvq+uxw7CmMdkZJCRYnjGFkFk3xZiaCJdEpLDuEeUB+2zPo7IgflIqlGBnckTcICfbn+fF228jLZUEp6jkyKMM+4v2XAv4nQBFSU8Acd7kGlAi9aiUMWLzG6XejDqPknDuY3S7stghxzXiqU953gf7qU45IDhVVarQFylwRnN5g5q4CJasfO9Jy3NDUNbLjj4JhY28c/7N6P6E8AKmhUYXvM5xQBskVCWRmCTSewih79SS5J30e5FePuAPblc4hDhWam8J01/iG0du95lieyjx/zuC7IDoTCgx+c9XkcEsN+gklBxNpCTuATPXT51Y/4doH0d+u1EILyTXoBU1TBlX1QVnP3gm/Yda/gWNKS925x/e7TXtUrdup14I8P3Ps= root@terraform"
}

#This is web ec2 code

resource "aws_instance" "web-server" {
  ami             = "ami-05caa5aa0186b660f"
  subnet_id       = aws_subnet.public-subnet.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_access.id}"]
  key_name        = "ltimindtreekey"
  tags = {
    Name     = "web-server"
    Stage    = "testing"
    Location = "chennai"
  }
}

#This is database ec2 code

resource "aws_instance" "data-server" {
  ami             = "ami-05caa5aa0186b660f"
  subnet_id       = aws_subnet.private-subnet.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.test_access.id}"]
  key_name        = "ltimindtreekey"
  tags = {
    Name     = "data-server"
    Stage    = "stage-base"
    Location = "delhi"
  }
}

#Create a public ip for Nat gateway

resource "aws_eip" "nat-eip" {
}

#Create Nat gateway

resource "aws_nat_gateway" "my-ngw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id
}

#create private route table

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-ngw.id
  }
  tags = {
    Name = "private-rt"
  }
}

#Route Table assosication code

resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
