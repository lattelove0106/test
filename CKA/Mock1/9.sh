#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 네임스페이스 생성
kubectl create ns frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns backend --dry-run=client -o yaml | kubectl apply -f -

# 1. 프런트엔드 Deployment 배포 (제공된 YAML)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: curlimages/curl
        command: ["sleep", "3600"]
EOF

# 2. 백엔드 Deployment 배포 (제공된 YAML)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
# 이미지 09 내용
echo -e "QUESTION: 09 NetworkPolicy"
echo -e "There are 2 deployments, Frontend and Backend"
echo -e "Frontend will be in frontend namespace and Backend will be in backend namespace."
echo ""
echo -e "Task:"
echo -e "Create a network policy to have interaction between frontend and backend deployment."
echo -e "The network policy has to be least permissive."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
