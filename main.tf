provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "mainvpc" {
	cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "main_subnet" {
    vpc_id     = aws_vpc.mainvpc.id
    cidr_block = "10.1.0.0/16"
    availability_zone = "us-east-1a"
}

resource "aws_security_group" "app_sg" {
    name        = "app-security-group"
    description = "Security group for the application"
	vpc_id = aws_vpc.mainvpc.id

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
	
	tags = {
		Name = "Server"
	}
	
	user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/{VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
	EOF
	
	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = file("C:/Users/kacpe/.awsLabKeys/default.pem")
		host = aws_instance.server.public_ip
	}
	
	provisioner "file" {
		source = "docker-compose.yml"
		destination = "/home/ec2-user/docker-compose.yml"
	}
	
	provisioner "remote-exec" {
		inline = [
			"cd /home/ec2-user",
			"docker-compose up -d"
		]
	}
		
	subnet_id = aws_subnet.main_subnet.id
	vpc_security_group_ids = [aws_security_group.app_sg.id]
}