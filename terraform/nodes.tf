resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.razan_cluster.name
  node_group_name = "razan-node-group"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # t3.medium provides 2 vCPU and 4GB RAM, perfect for Flask + Monitoring
  instance_types = ["t3.medium"]

  # This ensures permissions are ready before the nodes try to join the cluster
  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}