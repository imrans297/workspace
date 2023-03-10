
######VPC-CREation##############

resource "aws_vpc" "myvpc2" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MY_VPC-2"
  }
}

########IGW##########
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc2.id

  tags = {
    Name = "myigw1"
  }
}

########public-Subnet############
resource "aws_subnet" "publicSN" {
  vpc_id     = aws_vpc.myvpc2.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
#########Private-subnet#############
resource "aws_subnet" "privateSN" {
  vpc_id     = aws_vpc.myvpc2.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}

########Route-table############
resource "aws_route_table" "Public-rt" {
  vpc_id = aws_vpc.myvpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}    
  
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "Private-rt" {
  vpc_id = aws_vpc.myvpc2.id

  
  tags = {
    Name = "private-rt"
  }
}

###############Route-table-Association#############
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicSN.id
  route_table_id = aws_route_table.Public-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.privateSN.id
  route_table_id = aws_route_table.Private-rt.id
}

#################--------Public-Security-Group------------#####################
resource "aws_security_group" "pub_sg" {
  name        = "pub_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc2.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "all icmp"
    from_port        = 0
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "pub-security-Grp"
  }
}

###################----------Private-Security-Group-------###############
resource "aws_security_group" "prvt_sg" {
  name        = "prvt_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc2.id

ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "private-security-Grp"
  }
}

###########EC2-Creation########
resource "aws_instance" "linux-1" {
  ami           = "ami-0568773882d492fc8"
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  key_name = "ohiokey1"
  associate_public_ip_address = true
  subnet_id = aws_subnet.publicSN.id
  vpc_security_group_ids = [aws_security_group.pub_sg.id]

  tags = {
    Name = "public-1a"
  }
}