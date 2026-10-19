# ---------------------------------------------------------------------------
# Application server (private application subnet)
# ---------------------------------------------------------------------------

# Latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# IAM role so we can reach the server via SSM Session Manager (no SSH, no key pair, no port 22)
resource "aws_iam_role" "app" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.private_app[0].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = false

  # Enforce IMDSv2 (blocks SSRF-style metadata credential theft)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y httpd mariadb105
    systemctl enable --now httpd
    cat > /var/www/html/index.html <<'HTML'
    <h1>Secure Three-Tier App</h1>
    <p>Served from a private EC2 instance behind an Application Load Balancer.</p>
    HTML
  EOT

  tags = { Name = "${var.project_name}-app-server" }

  # NAT must exist first so user_data can download packages
  depends_on = [aws_nat_gateway.nat]
}
