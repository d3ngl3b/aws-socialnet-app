provider "aws" {
  region = "us-east-1"
}

### VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}

### SG
resource "aws_security_group" "calico_sg" {
  name        = var.sg_name
  description = "Allow SSH for inbound and traffic for calico network"
  vpc_id      = module.vpc.vpc_id

  ### SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ### BGP
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ### IP-in-IP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "4" # protocol number for IP-in-IP
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ### Kube API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ### etcd (if separate)
  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ### All outband traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}


### EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # "099720109477" canonical number, amazon also possible
}

resource "aws_instance" "k8s_control_plane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.calico_sg]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = var.control_instance_name
  }
}

resource "aws_instance" "k8s_worker_plane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  count = var.worker_count

  vpc_security_group_ids = [aws_security_group.calico_sg]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = "${var.control_instance_name}-${count.index}"
  }
}