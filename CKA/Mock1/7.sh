#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 네임스페이스 생성
kubectl create ns echo-sound --dry-run=client -o yaml | kubectl apply -f -

# 제공된 YAML로 echoserver-deployment 배포
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoserver-deployment
  namespace: echo-sound
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo
        image: gcr.io/google_containers/echoserver:1.10
        ports:
        - containerPort: 8080
EOF

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 07 Ingress Resource"
echo -e "Create a new ingress resource named echo in echo-sound namespace"
echo ""
echo -e "With the following tasks:"
echo -e "1. Expose the deployment with a service named echo-service on http://example.org/echo"
echo -e "   using Service port 8080 type=NodePort."
echo ""
echo -e "2. The availability of Service echo-service can be checked using the following command"
echo -e "   which should return 200:"
echo -e "   curl -o /dev/null -s -w \"%{http_code}\\\\n\" http://example.org/echo"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
