#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 고장 내기 (Setup Failure) ===${NC}"

# 1. kube-apiserver 매니페스트 경로 확인
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if [ ! -f "$MANIFEST" ]; then
    echo -e "${RED}에러: $MANIFEST 파일을 찾을 수 없습니다. 컨트롤 플레인 노드에서 실행하세요.${NC}"
    exit 1
fi

# 2. 백업 생성
sudo cp $MANIFEST ${MANIFEST}.bak

# 3. 문제 상황 재현: etcd 포트를 2379에서 2380으로 강제 변경
sudo sed -i 's/--etcd-servers=https:\/\/127.0.0.1:2379/--etcd-servers=https:\/\/127.0.0.1:2380/g' $MANIFEST

echo -e "${GREEN}환경 설정 완료:${NC}"
echo -e "- kube-apiserver가 etcd 피어 포트(2380)를 바라보도록 설정되었습니다."
echo -e "- 이제 kube-apiserver가 정상적으로 시작되지 않을 것입니다."
echo ""

echo -e "${BLUE}=== [2] 문제 (Question #14) ===${NC}"
echo -e "CONTEXT: After a cluster migration, the controlplane kube-apiserver is not coming up."
echo -e "CAUSE: kube-apiserver is pointing to etcd peer port 2380 instead of 2379."
echo -e "TASK: Fix it."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 해결(포트 수정)한 후 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. YAML 파일 내 포트 설정 확인
CURRENT_PORT=$(grep "2380" $MANIFEST)
if [ -z "$CURRENT_PORT" ]; then
    echo -e "1. Manifest Port Correction: ${GREEN}PASS${NC} (2380 포트 설정이 제거됨)"
else
    echo -e "1. Manifest Port Correction: ${RED}FAIL${NC} (여전히 2380 포트가 남아있습니다)"
fi

# 2. API 서버 응답 확인 (실제 동작 여부)
echo "API 서버 상태 확인 중 (최대 60초 대기)..."
for i in {1..12}; do
    kubectl get nodes &> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "2. kube-apiserver Status: ${GREEN}PASS (Running)${NC}"
        exit 0
    fi
    sleep 5
done

echo -e "2. kube-apiserver Status: ${RED}FAIL (서버가 여전히 응답하지 않습니다)${NC}"