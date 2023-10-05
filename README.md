
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Pods not scheduled preventing application scaling.
---

This incident type occurs when the pods in a Kubernetes cluster fail to schedule, which prevents the application from scaling. Kubernetes is a container orchestration platform that automates the deployment, scaling, and management of containerized applications. Pods in Kubernetes are the smallest deployable units that can be created and managed. When pods do not schedule, it means that the Kubernetes scheduler is unable to find a node with enough resources to run the pod. This can cause issues with application performance and scalability.

### Parameters
```shell
export NODE_NAME="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export RESOURCE_GROUP_NAME="PLACEHOLDER"

export NODE_TYPE="PLACEHOLDER"

export CLUSTER_NAME="PLACEHOLDER"

export NEW_NODE_COUNT="PLACEHOLDER"

export NODE_COUNT="PLACEHOLDER"
```

## Debug

### Check if pods are pending
```shell
kubectl get pods --field-selector=status.phase=Pending
```

### Check if there are enough resources available to schedule the pod
```shell
kubectl describe node ${NODE_NAME} | grep -i capacity
```

### Check if there are any taints or affinity rules preventing the pod from being scheduled
```shell
kubectl describe node ${NODE_NAME} | grep -i taint

kubectl describe pod ${POD_NAME} | grep -i node-selector
```

### Check if there are any events related to the pod scheduling failure
```shell
kubectl describe pod ${POD_NAME} | grep -i events
```

## Repair

### Check if there are enough resources available on the nodes to schedule the pods. If not, increase the resources on the nodes or provision new nodes by scaling eks cluster, azure cluster and gke cluster as repair
```shell
bash

#!/bin/bash



# Define variables

CLUSTER_NAME=${CLUSTER_NAME}

NODE_COUNT=${NODE_COUNT}

NODE_TYPE=${NODE_TYPE}

NEW_NODE_COUNT=${NEW_NODE_COUNT}



# Check if there are enough resources available on nodes to schedule the pods

if kubectl describe nodes | grep -E "CPU Requests|CPU Limits|Memory Requests|Memory Limits" | awk '{print $2}' | grep -v "\-"; then

  echo "There are enough resources available on the nodes to schedule the pods."

else

  echo "There are not enough resources available on the nodes to schedule the pods."



  # Increase resources on nodes or provision new nodes

  case $CLUSTER_NAME in

    eks)

      echo "Increasing resources on nodes or provisioning new nodes for EKS cluster."

      aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_TYPE --scaling-config minSize=$NODE_COUNT,maxSize=$NEW_NODE_COUNT,desiredSize=$NEW_NODE_COUNT

      ;;

    azure)

      echo "Increasing resources on nodes or provisioning new nodes for Azure cluster."

      az aks nodepool update --name $NODE_TYPE --cluster-name $CLUSTER_NAME --resource-group ${RESOURCE_GROUP_NAME} --node-count $NEW_NODE_COUNT

      ;;

    gke)

      echo "Increasing resources on nodes or provisioning new nodes for GKE cluster."

      gcloud container clusters resize $CLUSTER_NAME --node-pool $NODE_TYPE --size=$NEW_NODE_COUNT

      ;;

    *)

      echo "Invalid cluster name specified."

      exit 1

      ;;

  esac

fi


```