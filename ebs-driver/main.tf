
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


#Create ebs volume policy
resource "aws_iam_policy" "ebs-volume-policy" {
  count  = var.volume_count
  name   = "${var.name_prefix}-ebs-volume-${count.index + 1}"
  policy = data.aws_iam_policy_document.ebs-volume-policy[count.index].json
}

/**
 * ## Persistent EBS Volumes
 *
 * Create an arbitrary number of EBS volumes. By "persistent" we mean that these
 * volumes are separate from the EC2 instances they are attached to, and can be
 * attached to a new version of the previous instance when we need to replace the
 * instance (and we want to keep the service data).
 *
 * This module provides EBS volumes and associated IAM policies to be
 * used with an EC2 instances or auto-scaling groups. The `volume-mount-snippets`
 * module can be used to attach EBS volumes on boot. Volumes created will be
 * interleaved throughout the Avaialability Zones.
 *
 */
resource "aws_ebs_volume" "volumes" {
  count             = var.volume_count
  availability_zone = element(data.availability_zones.az.names, count.index)
  size              = var.size
  type              = var.volume_type

  encrypted   = var.encrypted
  kms_key_id  = var.encrypted ? var.kms_key_id : ""
  snapshot_id = element(var.snapshot_ids, count.index)
  tags = merge(
    {
      "Name" = "${var.name_prefix}-${format("%02d", count.index + 1)}-${element(data.availability_zones.az.names, count.index)}"
    },
    var.extra_tags,
  )
}

data "template_file" "volume_mount_snippets" {
  count    = var.volume_count
  template = file("${path.module}/snippet.tpl.sh")

  vars = {
    volume_id     = element(aws_ebs_volume.volumes.*.id, count.index)
    device_name   = var.device_name
    wait_interval = var.wait_interval
    max_wait      = var.max_wait
  }
}


###########################################################################################################
###########################################################################################################


# create ebs csi driver
resource "helm_release" "ebs_csi_driver" {
  name       = var.ebs_csi
  namespace  = var.namespace
  repository = "https://github.com/kubernetes-sigs/aws-ebs-csi-driver"
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

##################################################################################################################
####################################################################################################################