#output the iam role for ebs_csi_driver
output "ebs_csi_iam_role_arn" {
  value       = module.ebs_csi_eks_role.iam_role_arn
}