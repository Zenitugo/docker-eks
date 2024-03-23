# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks-role" {
    name               = var.cluster-rolename
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "eks.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
}
################################################################################################
################################################################################################

# Attach iam role to ekc cluster policy
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}
################################################################################################
################################################################################################

# Create an IAM role for EKS worker nodes
resource "aws_iam_role" "worker-node-role" {
    name                          = var.node-role-name
    assume_role_policy            = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "ec2.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })

}
################################################################################################
################################################################################################

# Attach the IAM policies to the EKS worker nodes
resource "aws_iam_role_policy_attachment" "WorkerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "CNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-node-role.name
}

resource "aws_iam_role_policy_attachment" "ContainerRegistry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-node-role.name
}

####################################################################################################
####################################################################################################

# Create IAM role for ebs csi driver
resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = var.role_name
}


# Create a policy attachment for iam role
resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

########################################################################################################
########################################################################################################

# Create Iam role for aws load balancer controller
resource "aws_iam_role" "load_balancer_controller" {
  assume_role_policy              = data.aws_iam_policy_document.controller.json
  name                            = var.controller_role_name
}

# Create a policy to the iam role of the load balancer controller
resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy                          = file("${path.module}/ingress-controller.json")
  name                            = var.controller_policy_name
}


# Attach a policy to the the role of the load balancer
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role                            = aws_iam_role.load_balancer_controller.name
  policy_arn                      = aws_iam_policy.aws_load_balancer_controller.arn
}