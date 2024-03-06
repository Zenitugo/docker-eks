data "aws_partition" "current_testing" {}

data "aws_caller_identity" "current_testing" {}

data "aws_eks_cluster" "cluster_testing" {
  name = var.cluster_name
}
