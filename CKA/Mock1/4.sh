#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 제공된 YAML 정보로 초기 WordPress 환경 배포
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-setup
        image: busybox
        command: ["sh", "-c", "echo 'Preparing environment...' && sleep 5"]
      containers:
      - name: wordpress
        image: wordpress:6.2-apache
        ports:
        - containerPort: 80
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 04"
echo -e "You are managing a WordPress application running in a Kubernetes cluster. ."
echo -e "Your task is to adjust the Pod resource requests and limits to ensure stable operation. Follow the instructions below:"
echo ""
echo -e "1. Scale down the wordpress Deployment to 0 replicas."
echo -e "2. Edit the Deployment and divide node resources evenly across all 3 Pods."
echo -e "3. Assign fair and equal CPU and memory requests to each Pod."
echo -e "4. Add sufficient overhead to avoid node instability."
echo ""
echo -e "Ensure that both the init containers and main containers use exactly the same resource requests and limits."
echo -e "After making the changes, scale the Deployment back to 3 replicas."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
