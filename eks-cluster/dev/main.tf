module "vpc" {
    source                   = "../child-modules/vpc"
    cidr_block               = var.cidr_block  
    public-subnets           = var.public-subnets
    private-subnets          = var.private-subnets 
}



module "EKS" {
    source                  = "../child-modules/EKS"
    cluster                 = var.cluster
    eks-cluster-role        = module.iam.eks-cluster-role
    private-subnet-ids      = module.vpc.private-subnet-ids 
    node-group              = var.node-group
    node-role               = module.iam.node-role
    eks-sg                  = module.EKS_SG.eks-sg
    instance_type           = var.instance_type 
    key_name                = var.key_name
    cluster-policy          = module.iam.cluster-policy
    WorkerPolicy            = module.iam.WorkerPolicy
    CNIPolicy               = module.iam.CNIPolicy
    ContainerRegistry       = module.iam.ContainerRegistry  
    public-subnet-ids       = module.vpc.public-subnet-ids 
}


module "EKS_SG" {
    source                  = "../child-modules/EKS-SG"
    vpc-id                  = module.vpc.vpc-id 
}



module "iam" {
    source                  = "../child-modules/iam"
    cluster-rolename        = var.cluster-rolename 
    node-role-name          = var.node-role-name 
    clustername             = module.EKS.clustername 
}

