provider "aws" {
  version = "~> 2.0"
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "thrucovid19" {
  key_name   = "thrucovid19"
  public_key = file("~/.ssh/thrucovid19.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.thrucovid19.key_name
  ami           = "ami-08f3d892de259504d"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/thrucovid19")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}
