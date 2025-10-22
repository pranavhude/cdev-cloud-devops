# -----------------------------
# Bastion Host (Jump Server)
# -----------------------------

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amzn2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create SSH key pair from a local public key file
resource "aws_key_pair" "default" {
  key_name   = "${var.project}-key"
  public_key = file(var.public_key_path)
}

# Bastion EC2 instance (uses security group defined in securitygroup.tf)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = element(values(aws_subnet.public)[*].id, 0)
  key_name                    = aws_key_pair.default.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y jq git
              echo "Bastion host ready" > /tmp/setup-status.txt
              EOF

  tags = {
    Name = "${var.project}-bastion"
  }

  depends_on = [aws_internet_gateway.igw]
}

