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
