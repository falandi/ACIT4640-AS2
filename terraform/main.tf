provider "aws" {
    region = "us-west-1"
}

resource "aws_vpc" "a02_vpc" {
  cidr_block       = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "a02_vpc"
  }
}

resource "aws_key_pair" "a02_keypair" {
  key_name   = "as2_key"
  public_key = file("/home/faefa/.ssh/as2_key.pub") 
}


resource "aws_subnet" "a02_pub_subnet" {
  vpc_id     = aws_vpc.a02_vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "a02_pub_subnet"
  }
}

resource "aws_subnet" "a02_priv_subnet" {
  vpc_id     = aws_vpc.a02_vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "a02_priv_subnet"
  }
}

resource "aws_internet_gateway" "a02_igw" {
  vpc_id = aws_vpc.a02_vpc.id

  tags = {
    Name = "a02_igw"
  }
}


resource "aws_route_table" "a02_route_table" {
  vpc_id = aws_vpc.a02_vpc.id

  
  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.a02_igw.id
  }
  
   tags = {
    Name = "a02_route_table"
    }
  }

resource "aws_route_table_association" "assoc_priv" {
  subnet_id      = aws_subnet.a02_priv_subnet.id
  route_table_id = aws_route_table.a02_route_table.id


    }

 resource "aws_route_table_association" "assoc_pub" {
  subnet_id      = aws_subnet.a02_pub_subnet.id
  route_table_id = aws_route_table.a02_route_table.id

}

resource "aws_security_group" "a03_priv_sg" {
  name        = "a03_priv_sg"
  vpc_id      = aws_vpc.a02_vpc.id
}

resource "aws_security_group" "a03_pub_sg" {
  name        = "a03_pub_sg"
  vpc_id      = aws_vpc.a02_vpc.id

} 

resource "aws_security_group_rule" "allow_source_to_destination_priv" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.a03_pub_sg.id
  security_group_id        = aws_security_group.a03_priv_sg.id
}

resource "aws_security_group_rule" "allow_source_to_destination_pub" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.a03_priv_sg.id
  security_group_id        = aws_security_group.a03_pub_sg.id
}

resource "aws_security_group" "a02_priv_sg" {
  vpc_id = aws_vpc.a02_vpc.id

  ingress {
    description      = "SSH from BCIT"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["142.232.0.0/16"]
  }

  ingress {
    description      = "SSH from Home"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.65.96.0/19"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "a02_pub_sg" {
  vpc_id = aws_vpc.a02_vpc.id

  ingress {
    description      = "SSH from Anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from BCIT"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["142.232.0.0/16"]
  }

  ingress {
    description      = "SSH from Home"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.65.96.0/19"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "a02_web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.a02_pub_subnet.id 
  key_name  = aws_key_pair.a02_keypair.id


   vpc_security_group_ids = [
    aws_security_group.a02_pub_sg.id
  ]

  tags = {
    Name = "AS2_Web_Server"
  }
}

resource "aws_instance" "a02_db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.a02_pub_subnet.id 
  key_name  = aws_key_pair.a02_keypair.id


   vpc_security_group_ids = [
    aws_security_group.a02_pub_sg.id
  ]

  tags = {
    Name = "AS2_Database"
  }
}

resource "aws_instance" "a02_backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.a02_priv_subnet.id 
  key_name  = aws_key_pair.a02_keypair.id

   vpc_security_group_ids = [
    aws_security_group.a02_pub_sg.id 
  ]


  tags = {
    Name = "AS2_Backend"
  }
}


