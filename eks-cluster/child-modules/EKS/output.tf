# Output cluster name
output "clustername" {
    value = aws_eks_cluster.eks-cluster.name
}