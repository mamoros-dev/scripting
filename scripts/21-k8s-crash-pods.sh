#!/bin/bash

# Identifica pods en bucle de reinicio en Kubernetes.
kubectl get pods --all-namespaces -o json | jq -r '
  .items[] | 
  select(.status.containerStatuses[].restartCount > 3) | 
  "Namespace: \(.metadata.namespace) | Pod: \(.metadata.name)"'