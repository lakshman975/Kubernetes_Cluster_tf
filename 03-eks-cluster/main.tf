module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "roboshop-tf"
  cluster_version = "1.27" ## We have to upgrade it from 1.27 to 1.28 to 1.29

  cluster_endpoint_public_access = true

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids)
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access
  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
      }
    }
    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
      }

    }
  }

  tags = var.common_tags
}


## Comment green and and deploy blue
## Run some pods on blue
## Uncomment green and run terraform apply
## Taint green(new) nodes
## kubectl taint nodes <NameOfTheNode> project=roboshop:NoExecute
## Upgrade the EKS manually in aws console. select 1.28 
## Once it is updated then worker nodes will also ask to upgrade don't upgrade the blue workernodes upgrade the green workernodes
## Taint blue nodes using below command because new pods shouldn't run on blue nodes
## kubectl taint nodes <NameOfTheNode> project=roboshop:NoSchedule
## Untain green
## kubectl taint nodes <NameOfTheNode> project=roboshop:NoExecute-
## cordon/drain the blue nodes so the pods inside the blue nodes will run on green nodes.
## kubectl drain --ignore-daemonsets <node_name> --force --delete-emptydir-data
## The same way we have upgrade to 1.29