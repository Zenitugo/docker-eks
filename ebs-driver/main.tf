
resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = var.role_name
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = var.addon_name
  addon_version            = "v1.11.4-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}