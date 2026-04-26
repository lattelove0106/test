#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 1. 네임스페이스 생성
kubectl create ns autoscale --dry-run=client -o yaml | kubectl apply -f -

# 2. 제공된 YAML로 apache-deployment 배포
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  namespace: autoscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache
        image: httpd
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
          limits:
            cpu: 200m
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 10 HPA"
echo -e "Create a new HorizontalPodAutoscaler [HPA] named apache-server in the autoscale namespace."
echo ""
echo -e "Tasks:"
echo -e "1. This HPA must target the existing deployment called apache-deployment in the autoscale namespace."
echo -e "2. Set the HPA to target for 50% CPU usage per Pod."
echo -e "3. Configure the HPA to have a minimum of 1 pod and maximum of 4 pods."
echo -e "   Also, we have to set the downscale stabilization window to 30 seconds."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
