# Output cluster name
output "clustername" {
    value = aws_eks_cluster.eks-cluster.name
}


# Output cluster identity
output "clustername" {
    value = aws_eks_cluster.eks-cluster.identity
}