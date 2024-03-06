# Output the arn of my eks cluster
output  "eks-cluster-role" {
    value   = aws_iam_role.eks-role.arn
}

# output the id of the node role
output "node-role" {
   value    = aws_iam_role.worker-node-role.arn  
}


# output the id of the iam policies
output "cluster-policy" {
    value   = aws_iam_role_policy_attachment.AmazonEKSClusterPolicy.id 
}

output "WorkerPolicy" {
    value   = aws_iam_role_policy_attachment.WorkerPolicy.id
  
}

output "CNIPolicy" {
    value   = aws_iam_role_policy_attachment.CNIPolicy.id
  
}

output "ContainerRegistry" {
    value   = aws_iam_role_policy_attachment.ContainerRegistry.id
  
}