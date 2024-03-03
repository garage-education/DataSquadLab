################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################
resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
  for_each = local.cluster_autoscaler_asg_tags

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key                 = each.value.key
    value               = each.value.value
    propagate_at_launch = false
  }
}