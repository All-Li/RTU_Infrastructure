provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-west-2"
}
data "aws_ami" "latest_Ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "aws_security_group" "BD_alizone" {
  name        = "WebServer Security Group"
  dynamic "ingress" {
    for_each = ["22", "80"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Bakalaura darba drošības grupa"
    Owner = "Alla Lizone"
  }
}
resource "aws_instance" "BD_alizone_Server" {
  count                  = 1
  ami                    = data.aws_ami.latest_Ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.BD_alizone.id]
  key_name               = "id_rsa_baka"
  tags = {
    Name  = "Mans Bakalaura darba serveris AWS vidē"
    Owner = "Alla Lizone"
  }
}