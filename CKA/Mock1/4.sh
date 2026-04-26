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
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. Replicas 확인
REPLICAS=$(kubectl get deployment wordpress -o jsonpath='{.spec.replicas}')
if [ "$REPLICAS" -eq 3 ]; then
    echo -e "1. Replicas (3): ${GREEN}PASS${NC}"
else
    echo -e "1. Replicas (3): ${RED}FAIL (현재: $REPLICAS)${NC}"
fi

# 2. Main Container Resources 확인 (Requests == Limits)
MAIN_REQ_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
MAIN_LIM_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')
MAIN_REQ_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
MAIN_LIM_MEM=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')

if [ ! -z "$MAIN_REQ_CPU" ] && [ "$MAIN_REQ_CPU" == "$MAIN_LIM_CPU" ] && [ "$MAIN_REQ_MEM" == "$MAIN_LIM_MEM" ]; then
    echo -e "2. Main Container (Req == Lim): ${GREEN}PASS${NC}"
else
    echo -e "2. Main Container (Req == Lim): ${RED}FAIL${NC}"
fi

# 3. Init Container Resources 확인 (Main과 동일 여부)
INIT_REQ_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources.requests.cpu}')
INIT_LIM_CPU=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources.limits.cpu}')

if [ ! -z "$INIT_REQ_CPU" ] && [ "$INIT_REQ_CPU" == "$MAIN_REQ_CPU" ] && [ "$INIT_REQ_CPU" == "$INIT_LIM_CPU" ]; then
    echo -e "3. Init Container (Same as Main): ${GREEN}PASS${NC}"
else
    echo -e "3. Init Container (Same as Main): ${RED}FAIL${NC}"
fi