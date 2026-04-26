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
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. HPA 존재 여부 및 대상 확인
TARGET=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
if [ "$TARGET" == "apache-deployment" ]; then
    echo -e "1. HPA Target (apache-deployment): ${GREEN}PASS${NC}"
else
    echo -e "1. HPA Target: ${RED}FAIL (Target: $TARGET)${NC}"
fi

# 2. CPU 타겟 및 복제본 범위 확인 (Min/Max/CPU)
MIN_PODS=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
MAX_PODS=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
CPU_VAL=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)

if [ "$MIN_PODS" == "1" ] && [ "$MAX_PODS" == "4" ] && [ "$CPU_VAL" == "50" ]; then
    echo -e "2. HPA Config (Min:1, Max:4, CPU:50%): ${GREEN}PASS${NC}"
else
    echo -e "2. HPA Config: ${RED}FAIL (Min:$MIN_PODS, Max:$MAX_PODS, CPU:$CPU_VAL)${NC}"
fi

# 3. Stabilization Window 확인
STAB_WIN=$(kubectl get hpa apache-server -n autoscale -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 2>/dev/null)
if [ "$STAB_WIN" == "30" ]; then
    echo -e "3. Downscale Stabilization (30s): ${GREEN}PASS${NC}"
else
    echo -e "3. Downscale Stabilization: ${RED}FAIL (현재값: ${STAB_WIN}s)${NC}"
fi