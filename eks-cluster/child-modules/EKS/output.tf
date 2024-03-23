# Output cluster name
output "clustername" {
    value = aws_eks_cluster.eks-cluster.name
}


# Output cluster identity
output "clusteridentity" {
    value = aws_eks_cluster.eks-cluster.identity
}


# Output openid_connect_provider url
output "openid-url" {
    value = aws_iam_openid_connect_provider.eks.url
}


# Output openid_connect_provider arn
output "openid-arn" {
    value = aws_iam_openid_connect_provider.eks.arn
}