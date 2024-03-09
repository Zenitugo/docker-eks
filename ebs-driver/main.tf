
locals {
  partition          = data.aws_partition.current_testing.id
  account_id         = data.aws_caller_identity.current_identity.account_id
  oidc_provider_arn  = replace(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_name = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider_arn}"
}

######################################################################################################################
####################################################################################################################

#Create ebs csi role

module "ebs_csi_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = var.role_name

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_name
      namespace_service_accounts = ["${var.namespace}:ebs-csi-controller-sa"]
    }
  }
}


###########################################################################################################
###########################################################################################################

# create ebs csi driver

resource "helm_release" "ebs_csi_driver" {
  name       = var.ebs_csi
  namespace  = var.namespace
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_eks_role.iam_role_arn
  }
}


################################################################################################################
#################################################################################################################

#Create storage class

resource "kubernetes_storage_class_v1" "storageclass_gp2" {
  depends_on = [helm_release.ebs_csi_driver, module.ebs_csi_eks_role]
  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }

}