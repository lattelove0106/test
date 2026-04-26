#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 제공된 YAML 정보로 초기 환경 배포
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:php8.2-apache
        command: ["/bin/sh", "-c", "while true; do echo 'WordPress is running...' >> /var/log/wordpress.log; sleep 5; done"]
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
spec:
  selector:
    app: wordpress
  ports:
    - port: 80
      targetPort: 80
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION 02:"
echo -e "Update the existing deployment wordpress, adding a sidecar container named sidecar using the busybox:stable image to the existing pod."
echo ""
echo -e "The new sidecar container has to run the following command: \"/bin/sh -c \"tail -f /var/log/wordpress.log\" use a volume mounted at /var/log to make the log file wordpress.log available to the co-located container"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# Sidecar 컨테이너 이름 및 이미지 확인
SIDECAR_IMG=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[?(@.name=="sidecar")].image}')

# 볼륨 마운트 경로 확인
MOUNT_PATH=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[?(@.name=="sidecar")].volumeMounts[?(@.mountPath=="/var/log")].mountPath}')

# 실행 커맨드 확인
COMMAND=$(kubectl get deployment wordpress -o jsonpath='{.spec.template.spec.containers[?(@.name=="sidecar")].command}')

if [ "$SIDECAR_IMG" == "busybox:stable" ]; then
    echo -e "1. Sidecar Container (busybox:stable): ${GREEN}PASS${NC}"
else
    echo -e "1. Sidecar Container (busybox:stable): ${RED}FAIL${NC}"
fi

if [ "$MOUNT_PATH" == "/var/log" ]; then
    echo -e "2. Volume Mount (/var/log): ${GREEN}PASS${NC}"
else
    echo -e "2. Volume Mount (/var/log): ${RED}FAIL${NC}"
fi

if [[ "$COMMAND" == *"tail -f /var/log/wordpress.log"* ]]; then
    echo -e "3. Sidecar Command: ${GREEN}PASS${NC}"
else
    echo -e "3. Sidecar Command: ${RED}FAIL${NC}"
fi