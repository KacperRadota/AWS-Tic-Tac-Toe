provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "mainvpc" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = true
	enable_dns_hostnames = true
}

resource "aws_subnet" "main_subnet" {
    vpc_id     = aws_vpc.mainvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "maingateway" {
	vpc_id = aws_vpc.mainvpc.id
}

resource "aws_route_table" "mainroutetable" {
	vpc_id = aws_vpc.mainvpc.id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.maingateway.id
	}
}

resource "aws_route_table_association" "main_subnet" {
	subnet_id = aws_subnet.main_subnet.id
	route_table_id = aws_route_table.mainroutetable.id
}

resource "aws_security_group" "app_sg" {
    name        = "app-security-group"
    description = "Security group for the application"
	vpc_id = aws_vpc.mainvpc.id
	
	  egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	  }

	  ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		description = "SSH"
		cidr_blocks = ["0.0.0.0/0"]
	  }

    ingress {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "server" {
	ami = "ami-051f8a213df8bc089"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	key_name = "default"
	
	tags = {
		Name = "Server"	
	}
	
	user_data = "${file("install.sh")}"
	
	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = file("C:/Users/kacpe/.awsLabKeys/default.pem")
		host = aws_instance.server.public_ip
	}
		
	subnet_id = aws_subnet.main_subnet.id
	vpc_security_group_ids = [aws_security_group.app_sg.id]
}