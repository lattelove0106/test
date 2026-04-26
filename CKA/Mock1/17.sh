#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] Environment Setup (Question #17) ===${NC}"

# 1. 네임스페이스 생성
kubectl create ns nginx-static --dry-run=client -o yaml | kubectl apply -f -

# 2. 자가 서명 인증서 및 시크릿 생성 (TLS 실습용)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=ITKiddie.k8s.local" &> /dev/null

kubectl create secret tls nginx-tls -n nginx-static \
  --cert=/tmp/tls.crt --key=/tmp/tls.key --dry-run=client -o yaml | kubectl apply -f -

# 3. 초기 ConfigMap 생성 (TLSv1.2, TLSv1.3 지원 상태로 고장 유도)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nginx-static
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443 ssl;
        ssl_certificate /etc/nginx/tls/tls.crt;
        ssl_certificate_key /etc/nginx/tls/tls.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        location / {
          return 200 "TLS Is Working IT Kiddie\n";
        }
      }
    }
EOF

# 4. Deployment 및 Service 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
  namespace: nginx-static
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: tls
          mountPath: /etc/nginx/tls
      volumes:
      - name: config
        configMap:
          name: nginx-config
      - name: tls
        secret:
          secretName: nginx-tls
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-static
  namespace: nginx-static
spec:
  ports:
  - port: 443
    targetPort: 443
    protocol: TCP
  selector:
    app: nginx-static
EOF

echo -e "${GREEN}환경 준비 완료: nginx-static 서비스가 TLSv1.2/1.3 모드로 실행 중입니다.${NC}"
echo ""
echo "There is an existing deployment called nginx-static in the nginx-static namespace."
echo "The deployment contains a ConfigMap that supports TLSv1.2 and TLSv1.3, and a Secret for TLS"
echo "There is a service called nginx-static in the nginx-static namespace that is currently exposing the deployment"
echo -e "${BLUE}=== [2] Task (Original English) ===${NC}"
echo -e "1. Configure the configmap to only support TLSv1.3"
echo -e "2. Add the IP address of the service in /etc/hosts and name ITKiddie.k8s.local"
echo -e "3. Verify using curl (TLSv1.2 should not work)"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
read -p "작업을 완료한 후 Enter를 누르면 결과 검증을 시작합니다..."

echo -e "\n${BLUE}=== [3] Validation Result ===${NC}"

# 1. ConfigMap 검증
CHECK_V12=$(kubectl get cm nginx-config -n nginx-static -o jsonpath='{.data.nginx\.conf}' | grep "TLSv1.2")
if [ -z "$CHECK_V12" ]; then
    echo -e "1. ConfigMap Hardening (Only TLSv1.3): ${GREEN}PASS${NC}"
else
    echo -e "1. ConfigMap Hardening (Only TLSv1.3): ${RED}FAIL (Still contains TLSv1.2)${NC}"
fi

# 2. /etc/hosts 검증
HOSTS_CHECK=$(grep "ITKiddie.k8s.local" /etc/hosts)
if [ ! -z "$HOSTS_CHECK" ]; then
    echo -e "2. /etc/hosts Configuration: ${GREEN}PASS${NC}"
else
    echo -e "2. /etc/hosts Configuration: ${RED}FAIL${NC}"
fi

# 3. 실제 접속 테스트
echo "Running connection tests..."
# TLSv1.2 실패 테스트
curl --tls-max 1.2 https://ITKiddie.k8s.local -k --connect-timeout 2 &> /tmp/tls_test
if [ $? -ne 0 ]; then
    echo -e "3-1. TLSv1.2 Restriction: ${GREEN}PASS (Connection Rejected)${NC}"
else
    echo -e "3-1. TLSv1.2 Restriction: ${RED}FAIL (TLSv1.2 still allowed)${NC}"
fi

# TLSv1.3 성공 테스트
curl --tlsv1.3 https://ITKiddie.k8s.local -k --connect-timeout 2 &> /tmp/tls_test
if [ $? -eq 0 ]; then
    echo -e "3-2. TLSv1.3 Access: ${GREEN}PASS (Success)${NC}"
else
    echo -e "3-2. TLSv1.3 Access: ${RED}FAIL (Please check if Pod is restarted after CM change)${NC}"
fi