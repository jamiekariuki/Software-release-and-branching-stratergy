module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app-vpc-${var.ENV_PREFIX}"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  manage_default_security_group = false
  manage_default_network_acl = false

  tags = {
    Terraform = "true"
    Environment = var.ENV_PREFIX
  }
}

//security groups
resource "aws_security_group" "web_sg" {
  name        = "web-${var.ENV_PREFIX}-sg"
  description = "allows all traffic to our web app and ssh"
  vpc_id      = module.vpc.vpc_id


  # Inbound rules → ingress
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules → egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ENV_PREFIX
  }
}

//instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "web-${var.ENV_PREFIX}-instance"

  ami = "ami-0360c520857e3138f"
  instance_type = "t3.micro"
  key_name      = "N.VIRGINIA-KEY"
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids    = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = module.ec2_ecr_role.instance_profile_name
  
  create_security_group = false

  user_data = <<-EOF
            #!/bin/bash
            apt-get update -y
            apt-get upgrade -y

            sudo apt-get update -y
            sudo apt-get install -y unzip

            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            cd aws
            sudo ./install
            aws --version

            apt-get install -y docker.io
            systemctl enable docker
            systemctl start docker
            usermod -aG docker ubuntu

            curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
          EOF

  tags = {
    Terraform   = "true"
    Environment = var.ENV_PREFIX
  }
}

//iam for github
module "iam_role_github_oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"
  name = "${var.ENV_PREFIX}-github-oidc-role"

  enable_github_oidc      = true
 
  oidc_subjects = [
  "jamiekariuki/Software-release-and-branching-stratergy:ref:refs/heads/main",
  "jamiekariuki/Software-release-and-branching-stratergy:ref:refs/heads/release/dev",
  "jamiekariuki/Software-release-and-branching-stratergy:ref:refs/heads/release/stage",
  "jamiekariuki/Software-release-and-branching-stratergy:ref:refs/heads/release/prod",
]


  policies = {
    ECRFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  }

  tags = {
    Terraform   = "true"
    Environment = var.ENV_PREFIX
  }
}

//iam for ec2
module "ec2_ecr_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "${var.ENV_PREFIX}-ec2-ecr-role"

  trust_policy_permissions = {
    ec2 = {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }]
    }
  }

  policies = {
    ECRReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  create_instance_profile = true

  tags = {
    Terraform   = "true"
    Environment = var.ENV_PREFIX
  }
}


//ecr
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.ENV_PREFIX}-repository"

  repository_read_write_access_arns = [module.iam_role_github_oidc.arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = var.ENV_PREFIX
  }
}