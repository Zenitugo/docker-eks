# Create an EKS Cluster
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster
  role_arn = var.eks-cluster-role

  

  vpc_config {
    # private subnets to configure kubernetes nodes and public to expose services from kubernetes to the internet by using load balancer
    subnet_ids = concat(var.private-subnet-ids, var.public-subnet-ids) 
  }
 
  depends_on = [
    var.eks-cluster-role,
    var.cluster-policy
  ]
}

##########################################################################################################################################
##########################################################################################################################################
# Create the EKS NODE GROUP
resource "aws_eks_node_group" "ec2-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.node-group
  node_role_arn   = var.node-role
  subnet_ids      = var.private-subnet-ids
  

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = [var.instance_type]

  remote_access {
    ec2_ssh_key   = var.key_name
    source_security_group_ids = [var.eks-sg]
  }


  depends_on = [
    var.WorkerPolicy,
    var.CNIPolicy,
    var.ContainerRegistry,
  ]
}

################################################################################################################################################################
################################################################################################################################################################

# Create an iam OIDC identity provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

  depends_on = [ aws_eks_cluster.eks-cluster ]
}

###################################################################################################################################################################
###################################################################################################################################################################

# Create ebs csi drive on eks
resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.eks-cluster.name
  addon_name               = var.addon_name
  addon_version            = data.aws_eks_addon_version.latest.version
  service_account_role_arn = var.ebs-csi-role

  depends_on = [ aws_iam_openid_connect_provider.eks ]

}