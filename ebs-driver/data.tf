data "aws_partition" "current_testing" {}

data "aws_caller_identity" "current_identity" {}

data "aws_eks_cluster" "eks-cluster" {
  name = "my-eks-cluster"
}

data "aws_iam_policy_document" "ebs-volume-policy" {
  count = var.volume_count
  statement {
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]

    resources = [
      "arn:${data.aws_partition.current_testing.partition}:${data.aws_caller_identity.current_identity.account_id}:volume/${element(aws_ebs_volume.volumes.*.id, count.index)}",
      "arn:${data.aws_partition.current_testing.partition}:${data.aws_caller_identity.current_identity.account_id}:instance/*",
    ]
  }
}

data "availability_zones" "az" {}