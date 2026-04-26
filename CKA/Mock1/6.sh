#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 네임스페이스 생성
kubectl create ns priority --dry-run=client -o yaml | kubectl apply -f -

# 1. 우선순위 클래스 (high-priority) 생성
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "사용자 정의 우선순위 클래스 중 가장 높은 클래스"
EOF

# 2. Deployment (busybox-logger) 배포
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "while true; do echo 'logging...'; sleep 5; done"]
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 06 Priority Class"
echo -e "You're working in a Kubernetes cluster with an existing Deployment named busybox-logger running in a namespace called priority."
echo -e "The cluster already has at least one user-defined Priority Class"
echo ""
echo -e "Perform the following tasks:"
echo -e "1. Create a new Priority Class named high-priority for user workloads. The value of this Priority Class should be exactly one less than the highest existing user-defined Priority Class value."
echo -e "2. Patch the existing Deployment busybox-logger in the priority namespace to use the newly created high-priority Priority Class"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. Priority Class 값 검증 (1000에서 1 적은 999인지 확인)
PC_VALUE=$(kubectl get pc high-priority -o jsonpath='{.value}' 2>/dev/null)
if [ "$PC_VALUE" == "999" ]; then
    echo -e "1. Priority Class Value (999): ${GREEN}PASS${NC}"
else
    echo -e "1. Priority Class Value (999): ${RED}FAIL (현재값: $PC_VALUE)${NC}"
fi

# 2. Deployment에 Priority Class 적용 여부 검증
PC_NAME=$(kubectl get deployment busybox-logger -n priority -o jsonpath='{.spec.template.spec.priorityClassName}' 2>/dev/null)
if [ "$PC_NAME" == "high-priority" ]; then
    echo -e "2. Deployment Priority Class Patch: ${GREEN}PASS${NC}"
else
    echo -e "2. Deployment Priority Class Patch: ${RED}FAIL (현재값: $PC_NAME)${NC}"
fi