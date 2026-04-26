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
read -p "Press Enter after you complete the tasks to start validation..."

echo -e "\n${BLUE}=== [3] Validation Result ===${NC}"

# 1. Check Service Name and Type
SVC_TYPE=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.type}' 2>/dev/null)
if [[ "$SVC_TYPE" == "NodePort" ]]; then
    echo -e "1. Service Type (NodePort): ${GREEN}PASS${NC}"
else
    echo -e "1. Service Type (NodePort): ${RED}FAIL${NC} (Current type: $SVC_TYPE)"
fi

# 2. Check Port Configuration
PORT_NAME=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].name}' 2>/dev/null)
PORT_NUM=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [[ "$PORT_NAME" == "http" && "$PORT_NUM" == "80" ]]; then
    echo -e "2. Port Configuration (80/http): ${GREEN}PASS${NC}"
else
    echo -e "2. Port Configuration (80/http): ${RED}FAIL${NC} (Name: $PORT_NAME, Port: $PORT_NUM)"
fi

# 3. Check TargetPort & Protocol
TARGET_PORT=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
PROTO=$(kubectl get svc nodeport-service -n relative -o jsonpath='{.spec.ports[0].protocol}' 2>/dev/null)
if [[ "$TARGET_PORT" == "80" && "$PROTO" == "TCP" ]]; then
    echo -e "3. Target & Protocol (80/TCP): ${GREEN}PASS${NC}"
else
    echo -e "3. Target & Protocol (80/TCP): ${RED}FAIL${NC}"
fi