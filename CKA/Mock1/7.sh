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
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. 서비스 생성 및 설정 확인 (포트 8080, NodePort)
SVC_PORT=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
SVC_TYPE=$(kubectl get svc echo-service -n echo-sound -o jsonpath='{.spec.type}' 2>/dev/null)

if [ "$SVC_PORT" == "8080" ] && [ "$SVC_TYPE" == "NodePort" ]; then
    echo -e "1. Service (echo-service: 8080, NodePort): ${GREEN}PASS${NC}"
else
    echo -e "1. Service (echo-service): ${RED}FAIL (Port: $SVC_PORT, Type: $SVC_TYPE)${NC}"
fi

# 2. Ingress 리소스 생성 확인 (호스트 및 경로)
ING_HOST=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
ING_PATH=$(kubectl get ingress echo -n echo-sound -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)

if [ "$ING_HOST" == "example.org" ] && [ "$ING_PATH" == "/echo" ]; then
    echo -e "2. Ingress (echo: example.org/echo): ${GREEN}PASS${NC}"
else
    echo -e "2. Ingress (echo): ${RED}FAIL (Host: $ING_HOST, Path: $ING_PATH)${NC}"
fi