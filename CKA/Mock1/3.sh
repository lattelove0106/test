#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup Environment) ===${NC}"

# 1단계: Gateway API CRD 설치
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.1.0"

# 2단계: 네임스페이스 생성
kubectl create ns web-app --dry-run=client -o yaml | kubectl apply -f -

# 3~4단계: Deployment 및 Service 배포
cat <<EOF | kubectl apply -n web-app -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

# 5~6단계: TLS 인증서 생성 및 Secret 등록
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=gateway.web.k8s.local/O=web" &> /dev/null

kubectl create secret tls web-tls --cert=tls.crt --key=tls.key -n web-app
rm -f tls.crt tls.key

# 7단계: 기존 Ingress 리소스 생성
cat <<EOF | kubectl apply -n web-app -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

# 마지막 단계: GatewayClass 생성
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-class
spec:
  controllerName: example.net/nginx-gateway-controller
EOF

echo -e "${GREEN}환경 구축이 완료되었습니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 03"
echo -e "You have an existing web application deployed in a Kubernetes cluster using an Ingress resource named web."
echo -e "You must migrate the existing Ingress configuration to the new Kubernetes Gateway API, maintaining the existing HTTPS access configuration."
echo ""
echo -e "Tasks:"
echo -e "- Create a Gateway resource named web-gateway with hostname gateway.web.k8s.local that maintains the existing TLS and listener configuration."
echo -e "- Create an HTTPRoute resource named web-route with hostname gateway.web.k8s.local that maintains the existing routing rules."
echo ""
echo -e "Note: A GatewayClass named nginx-class is already installed in the cluster."
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. Gateway 리소스 검증
GW_CHECK=$(kubectl get gateway web-gateway -n web-app --no-headers 2>/dev/null)
if [[ "$GW_CHECK" == *"web-gateway"* ]]; then
    GW_TLS=$(kubectl get gateway web-gateway -n web-app -o jsonpath='{.spec.listeners[0].tls.certificateRefs[0].name}')
    if [ "$GW_TLS" == "web-tls" ]; then
        echo -e "1. Gateway Resource (web-gateway & TLS): ${GREEN}PASS${NC}"
    else
        echo -e "1. Gateway Resource (web-gateway): ${GREEN}PASS${NC} / TLS Secret: ${RED}FAIL${NC}"
    fi
else
    echo -e "1. Gateway Resource (web-gateway): ${RED}FAIL${NC}"
fi

# 2. HTTPRoute 리소스 검증
ROUTE_CHECK=$(kubectl get httproute web-route -n web-app --no-headers 2>/dev/null)
if [[ "$ROUTE_CHECK" == *"web-route"* ]]; then
    ROUTE_HOST=$(kubectl get httproute web-route -n web-app -o jsonpath='{.spec.hostnames[0]}')
    if [ "$ROUTE_HOST" == "gateway.web.k8s.local" ]; then
        echo -e "2. HTTPRoute Resource (web-route & Hostname): ${GREEN}PASS${NC}"
    else
        echo -e "2. HTTPRoute Resource (web-route): ${GREEN}PASS${NC} / Hostname: ${RED}FAIL${NC}"
    fi
else
    echo -e "2. HTTPRoute Resource (web-route): ${RED}FAIL${NC}"
fi