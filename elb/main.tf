provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

# Get list of all availability zones 

data "aws_availability_zones" "all" {}

# Get the ami id for ubuntu linux bionic

data "aws_ami" "ubuntu-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

# Create a launch configuration 

resource "aws_launch_configuration" "tf-launch-config" {
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type in us-east-2
  image_id        = data.aws_ami.ubuntu-linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.tf-instance-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  # Whenever using a launch configuration with an auto scaling group, you must set create_before_destroy = true.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

# Create auto-scaling group

resource "aws_autoscaling_group" "tf-asg" {
  launch_configuration = aws_launch_configuration.tf-launch-config.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 5

  load_balancers    = [aws_elb.tf-elb.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "tf-asg"
    propagate_at_launch = true
  }
}

# Create an ELB to route traffic across auto scaling group

resource "aws_elb" "tf-elb" {
  name               = "tf-asg-elb"
  security_groups    = [aws_security_group.tf-elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

# Create security group

resource "aws_security_group" "tf-instance-sg" {
  name = "tf-http-sg"

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create elb security group

resource "aws_security_group" "tf-elb-sg" {
  name = "tf-elb-sg"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}