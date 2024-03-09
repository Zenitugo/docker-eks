data "aws_partition" "current_testing" {}

data "aws_caller_identity" "current_identity" {}

data "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
}
