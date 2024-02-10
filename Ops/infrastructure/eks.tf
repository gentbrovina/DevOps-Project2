resource "aws_eks_cluster" "demo" {
    name = "demo"
    role_arn = aws_iam_role.demo.arn

    vpc_config {
        subnet_ids = [
            aws_subnet.private-us-east-1a.id,
            aws_subnet.private-us-east-1b.id,
            aws_subnet.public-us-east-1a.id,
            aws_subnet.public-us-east-1b.id
        ]
    }
      depends_on = [ aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy ]
}

resource "aws_eks_node_group" "private-nodes" {
    cluster_name = aws_eks_cluster.demo.name
    node_group_name = "private-nodes"
    node_role_arn = aws_iam_role.nodes.arn

    subnet_ids = [
        aws_subnet.private-us-east-1a.id,
        aws_subnet.private-us-east-1b.id 
    ]
   capacity_type = "ON_DEMAND"
   instance_types = ["t3.small"]

   scaling_config {
     desired_size = 1
     max_size = 5
     min_size = 0
   }

   update_config {
    max_unavailable = 1
   }

   labels = {
    role = "genereal"
   }
}
