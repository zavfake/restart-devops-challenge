provider "aws" {
  region  = "ap-southeast-3"
  profile = "restart"
}

data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0c82cd70874a842cf"]
  }
}

resource "aws_security_group" "challenge_sg" {
  name        = "challenge_sg"
  description = "Security group for the challenge instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "challenge" {
  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.challenge_sg.id]

  tags = {
    Name = "AWSrestart"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd git
              systemctl start httpd
              systemctl enable httpd
              cd /var/www/html
              sudo chown ec2-user .
              git clone https://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@github.com/zavfake/restart-devops-challenge.git
              sudo cp restart-devops-challenge/hello.html /var/www/html/index.html
              sudo rm -rf restart-devops-challenge
              EOF
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.challenge.public_ip
}
