cidr_block                  = "10.0.0.0/16" 
region                      = "eu-west-1"
private-subnets             = ["10.0.1.0/24", "10.0.2.0/24"] 
public-subnets              = ["10.0.3.0/24", "10.0.4.0/24"]
cluster                     = "my-eks-cluster"
node-group                  = "my-eks-nodes"
instance_type               = "t2.medium"  
key_name                    = "care-key"
cluster-rolename            = "EKSClusterRole" 
node-role-name              = "EKSWorkerNodes" 
addon_name                  = "aws-ebs-csi-driver"
role_name                   = "eks-ebs-csi-driver"

