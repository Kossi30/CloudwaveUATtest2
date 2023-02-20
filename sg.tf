
resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "security group for RDS database"

  ingress {
    from_port       = local.db_from
    to_port         = local.db_to
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id] // allow traffic from app-sg
  }
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "security group for Application"

  ingress {
    from_port       = local.from_app
    to_port         = local.to_app
    protocol        = "tcp"
    security_groups = [aws_security_group.jmp-sg.id] // allow traffic from jmp-sg
  }

  ingress {
    from_port       = local.ssh_from
    to_port         = local.ssh_to
    protocol        = "tcp"
    cidr_blocks = [cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 3)) + 1)]
    security_groups = [aws_security_group.jmp-sg.id] // allow ssh from jump-box-sg
  }
  ingress {
    from_port       = local.ssh_from
    to_port         = local.ssh_to
    protocol        = "tcp"
    cidr_blocks     = [var.ssh_cidr] // allow ssh from specific IP
    security_groups = [aws_security_group.jmp-sg.id] // allow ssh from jump-box-sg
  }

  ingress {
    from_port       = local.rdp_from
    to_port         = local.rdp_to
    protocol        = "tcp"
    security_groups = [aws_security_group.jmp-sg.id] // allow RDP from jump-box-sg
  }

  ingress {
    from_port   = -1 // allow all ICMP traffic
    to_port     = -1 // allow all ICMP traffic
    protocol    = "icmp" // allow ICMP traffic
    security_groups = [aws_security_group.jmp-sg.id] // allow traffic from jmp-sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.vpc.id
}




resource "aws_security_group" "jmp-sg" {
  name        = "jmp-sg"
  description = "security group for Jump Box"

  ingress {
    from_port   = local.ssh_from
    to_port     = local.ssh_to
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.rdp_from
    to_port     = local.rdp_to
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.http_from
    to_port     = local.http_to
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.vpc.id
}