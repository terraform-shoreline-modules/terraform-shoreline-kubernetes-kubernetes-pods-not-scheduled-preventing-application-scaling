resource "shoreline_notebook" "kubernetes_pods_not_scheduled_preventing_application_scaling" {
  name       = "kubernetes_pods_not_scheduled_preventing_application_scaling"
  data       = file("${path.module}/data/kubernetes_pods_not_scheduled_preventing_application_scaling.json")
  depends_on = [shoreline_action.invoke_node_taints_and_pod_selector,shoreline_action.invoke_increase_node_resources_or_provision_new_nodes]
}

resource "shoreline_file" "node_taints_and_pod_selector" {
  name             = "node_taints_and_pod_selector"
  input_file       = "${path.module}/data/node_taints_and_pod_selector.sh"
  md5              = filemd5("${path.module}/data/node_taints_and_pod_selector.sh")
  description      = "Check if there are any taints or affinity rules preventing the pod from being scheduled"
  destination_path = "/agent/scripts/node_taints_and_pod_selector.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "increase_node_resources_or_provision_new_nodes" {
  name             = "increase_node_resources_or_provision_new_nodes"
  input_file       = "${path.module}/data/increase_node_resources_or_provision_new_nodes.sh"
  md5              = filemd5("${path.module}/data/increase_node_resources_or_provision_new_nodes.sh")
  description      = "Check if there are enough resources available on the nodes to schedule the pods. If not, increase the resources on the nodes or provision new nodes by scaling eks cluster, azure cluster and gke cluster as repair"
  destination_path = "/agent/scripts/increase_node_resources_or_provision_new_nodes.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_node_taints_and_pod_selector" {
  name        = "invoke_node_taints_and_pod_selector"
  description = "Check if there are any taints or affinity rules preventing the pod from being scheduled"
  command     = "`chmod +x /agent/scripts/node_taints_and_pod_selector.sh && /agent/scripts/node_taints_and_pod_selector.sh`"
  params      = ["NODE_NAME","POD_NAME"]
  file_deps   = ["node_taints_and_pod_selector"]
  enabled     = true
  depends_on  = [shoreline_file.node_taints_and_pod_selector]
}

resource "shoreline_action" "invoke_increase_node_resources_or_provision_new_nodes" {
  name        = "invoke_increase_node_resources_or_provision_new_nodes"
  description = "Check if there are enough resources available on the nodes to schedule the pods. If not, increase the resources on the nodes or provision new nodes by scaling eks cluster, azure cluster and gke cluster as repair"
  command     = "`chmod +x /agent/scripts/increase_node_resources_or_provision_new_nodes.sh && /agent/scripts/increase_node_resources_or_provision_new_nodes.sh`"
  params      = ["CLUSTER_NAME","RESOURCE_GROUP_NAME","NEW_NODE_COUNT","NODE_TYPE","NODE_COUNT"]
  file_deps   = ["increase_node_resources_or_provision_new_nodes"]
  enabled     = true
  depends_on  = [shoreline_file.increase_node_resources_or_provision_new_nodes]
}

