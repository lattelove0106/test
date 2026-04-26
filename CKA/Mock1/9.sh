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
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 네트워크 정책 존재 여부 및 설정 검증
NP_NAME=$(kubectl get netpol -n backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$NP_NAME" ]; then
    echo -e "1. NetworkPolicy Created in 'backend' namespace: ${GREEN}PASS${NC} (Name: $NP_NAME)"
    
    # 최소 권한(포트 80 및 frontend 네임스페이스 허용) 여부 확인
    ALLOW_PORT=$(kubectl get netpol "$NP_NAME" -n backend -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
    if [ "$ALLOW_PORT" == "80" ]; then
        echo -e "2. Least Permissive (Port 80 Restricted): ${GREEN}PASS${NC}"
    else
        echo -e "2. Least Permissive (Port 80 Restricted): ${RED}FAIL${NC}"
    fi
else
    echo -e "1. NetworkPolicy Created: ${RED}FAIL (backend 네임스페이스에 정책이 없음)${NC}"
fi