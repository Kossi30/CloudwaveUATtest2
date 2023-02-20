

data "aws_iam_policy_document" "s3-access" {
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::my-bucket/*"]
  }
}

resource "aws_iam_policy" "s3-access" {
  name   = "s3-access"
  policy = data.aws_iam_policy_document.s3-access.json
}

resource "aws_iam_policy" "efs_policy" {
  name = "EC2_EFS_Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.efs_with_lifecyle_policy.arn
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "EC2_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = aws_iam_policy.s3-access.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "efs_policy_attachment" {
  policy_arn = aws_iam_policy.efs_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_Profile"

  role = aws_iam_role.ec2_role.name
}









# # data "aws_iam_policy_document" "s3-access" {
# #   statement {
# #     actions   = ["s3:*"]
# #     resources = ["arn:aws:s3:::my-bucket/*"]
# #   }
# # }

# # resource "aws_iam_policy" "s3-access" {
# #   name   = "s3-access"
# #   policy = data.aws_iam_policy_document.s3-access.json
# # }

# # resource "aws_iam_role" "s3-access" {
# #   name = "s3-access"

# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Allow"
# #         Principal = {
# #           Service = "ec2.amazonaws.com"
# #         }
# #         Action = "sts:AssumeRole"
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_role_policy_attachment" "s3-access" {
# #   policy_arn = aws_iam_policy.s3-access.arn
# #   role       = aws_iam_role.s3-access.name
# # }

# # resource "aws_iam_instance_profile" "s3-access" {
# #   name = "s3-access"

# #   role = aws_iam_role.s3-access.name
# # }

# # resource "aws_iam_role" "ec2_role" {
# #   name = "EC2_EFS_Role"

# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Allow"
# #         Principal = {
# #           Service = "ec2.amazonaws.com"
# #         }
# #         Action = "sts:AssumeRole"
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_policy" "efs_policy" {
# #   name = "EC2_EFS_Policy"

# #   policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Allow"
# #         Action = [
# #           "elasticfilesystem:ClientMount",
# #           "elasticfilesystem:ClientWrite"
# #         ]
# #         Resource = aws_efs_file_system.efs_with_lifecyle_policy.arn
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
# #   policy_arn = aws_iam_policy.efs_policy.arn
# #   role       = aws_iam_role.ec2_role.name
# # }

# # resource "aws_iam_instance_profile" "ec2_instance_profile" {
# #   name = "EC2_Instance_Profile"

# #   role = aws_iam_role.ec2_role.name
# # }

