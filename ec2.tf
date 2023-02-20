
resource "aws_instance" "jump_box" {
  count                       = length(slice(data.aws_availability_zones.az.names, 0, 2))
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.jumpbox-key.key_name // specify the key pair
  tenancy                     = "default"
  monitoring                  = true
  subnet_id                   = element(aws_subnet.external[*].id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jmp-sg.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    insecure    = true

    timeout = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${sensitive(aws_key_pair.app-key.public_key)}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
      "rm -f ~/app-key.pem",
      "exit"
    ]
  }

  tags = {
    Name = "Jump-Box-${count.index}"
  }
}

resource "aws_instance" "app_server" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.app-key.key_name
  tenancy                = "default"
  monitoring             = true
  subnet_id              = element(aws_subnet.internal[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.app-sg.id, aws_security_group.jmp-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  private_ip             = cidrhost(aws_subnet.internal[count.index].cidr_block, 4 + count.index)

  user_data = <<-EOF
    #!/bin/bash
    echo '${sensitive(aws_key_pair.app-key.public_key)}' >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    rm -f ~/app-key.pem
    exit 0
  EOF

  tags = {
    Name = "Application-Server-${count.index}"
  }
}


# resource "aws_instance" "app_server" {
#   count = length(slice(data.aws_availability_zones.az.names, 0, 2))

#   ami                    = var.ami_id
#   instance_type          = "t3.micro"
#   key_name               = aws_key_pair.app-key.key_name
#   tenancy                = "default"
#   monitoring             = true
#   subnet_id              = element(aws_subnet.internal[*].id, count.index)
#   vpc_security_group_ids = [aws_security_group.app-sg.id, aws_security_group.jmp-sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
#   private_ip = cidrhost(aws_subnet.internal[count.index].cidr_block, 4 + count.index)
  
#   connection {
#     type        = "ssh"
#     host        = self.private_ip
#     user        = "ec2-user"
#     private_key = file("~/.ssh/id_rsa")
#     insecure    = true
#     timeout     = "5m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo '${sensitive(aws_key_pair.app-key.public_key)}' >> ~/.ssh/authorized_keys",
#       "chmod 600 ~/.ssh/authorized_keys",
#       "rm -f ~/app-key.pem",
#       "exit"
#     ]
#   }

#   tags = {
#     Name = "Application-Server-${count.index}"
#   }
# }

# resource "null_resource" "check_ssh" {
#   depends_on = [
#     aws_instance.app_server
#   ]

#   connection {
#     type        = "ssh"
#     host        = aws_instance.app_server.*.private_ip[length(aws_instance.app_server.*.private_ip)-1]
#     user        = "ec2-user"
#     private_key = file("~/.ssh/id_rsa")
#     timeout     = "10m"
#   }

#   provisioner "local-exec" {
#     command = "echo 'SSH Connection successful'"
#   }
# }

# resource "aws_instance" "app_server" {
#   count = length(slice(data.aws_availability_zones.az.names, 0, 2))

#   ami                    = var.ami_id
#   instance_type          = "t3.micro"
#   key_name               = aws_key_pair.app-key.key_name
#   tenancy                = "default"
#   monitoring             = true
#   subnet_id              = element(aws_subnet.internal[*].id, count.index)
#   vpc_security_group_ids = [aws_security_group.app-sg.id, aws_security_group.jmp-sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  
#   connection {
#     type        = "ssh"
#     host        = self.private_ip
#     user        = "ec2-user"
#     private_key = file("~/.ssh/id_rsa")
#     insecure    = true
#     timeout     = "5m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo '${sensitive(aws_key_pair.app-key.public_key)}' >> ~/.ssh/authorized_keys",
#       "chmod 600 ~/.ssh/authorized_keys",
#       "rm -f ~/app-key.pem",
#       "exit"
#     ]
#   }

#   tags = {
#     Name = "Application-Server-${count.index}"
#   }
# }




# resource "aws_instance" "app_server" {
#   count = length(slice(data.aws_availability_zones.az.names, 0, 2))

#   ami                    = var.ami_id
#   instance_type          = "t3.micro"
#   key_name               = aws_key_pair.app-key.key_name
#   tenancy                = "default"
#   monitoring             = true
#   subnet_id              = element(aws_subnet.internal[*].id, count.index)
#   vpc_security_group_ids = [aws_security_group.app-sg.id, aws_security_group.jmp-sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

#   connection {
#     type        = "ssh"
#     host        = self.private_ip
#     user        = "ec2-user"
#     private_key = file("~/.ssh/id_rsa")
#     insecure    = true
#     timeout     = "5m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo '${aws_key_pair.app-key.public_key}' >> ~/.ssh/authorized_keys",
#       "chmod 600 ~/.ssh/authorized_keys",
#       "rm -f ~/app-key.pem",
#       "exit"
#     ]
#   }

#   tags = {
#     Name = "Application-Server-${count.index}"
#   }

#   volume_tags = {
#     Name      = "EFS_TEST_ROOT"
#     Terraform = "true"
#   }
# }

resource "aws_efs_file_system" "efs_with_lifecyle_policy" {
  creation_token = "efs_shared_info"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}


resource "aws_efs_mount_target" "efs_mt" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  file_system_id = aws_efs_file_system.efs_with_lifecyle_policy.id
  subnet_id      = element(aws_subnet.internal[*].id, count.index)
}

resource "aws_instance" "db_server" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.db-key.key_name
  tenancy                = "default"
  monitoring             = true
  subnet_id              = element(aws_subnet.internal_db[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.db-sg.id]


  tags = {
    Name = "Database-Server-${count.index}"
  }
}