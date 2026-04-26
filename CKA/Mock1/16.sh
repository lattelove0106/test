#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] Environment Setup ===${NC}"

# 1. Create 'relative' namespace
kubectl create ns relative --dry-run=client -o yaml | kubectl apply -f -

# 2. Create 'nodeport-deployment'
kubectl apply -n relative -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodeport-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nodeport-app
  template:
    metadata:
      labels:
        app: nodeport-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: http
EOF

echo -e "${GREEN}Setup Completed: 'nodeport-deployment' is running in 'relative' namespace.${NC}"
echo ""

echo -e "${BLUE}=== [2] QUESTION: #16 NodePort ===${NC}"
echo -e "Ther is a deployment named nodeport-deployment in the relative namespace.
echo -e "Tasks:"
echo -e "1. Configure the deployment so it can be exposed using port 80 and protocol TCP name http."
echo -e "2. Create a new Service named nodeport-service exposing the container port 80 and TCP."
echo -e "3. Configure the new Service to also expose the individual pods using NodePort."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
