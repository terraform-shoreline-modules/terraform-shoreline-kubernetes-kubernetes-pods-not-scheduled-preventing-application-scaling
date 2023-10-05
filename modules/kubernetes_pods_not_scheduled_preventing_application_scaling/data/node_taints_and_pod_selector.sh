kubectl describe node ${NODE_NAME} | grep -i taint

kubectl describe pod ${POD_NAME} | grep -i node-selector