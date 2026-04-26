#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# 기존 스토리지 클래스가 있다면 기본 설정 해제 (실습 환경 초기화)
kubectl get sc -o name | xargs -I {} kubectl annotate {} storageclass.kubernetes.io/is-default-class- &> /dev/null

echo -e "${GREEN}환경 구축 완료.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 05"
echo ""
echo -e "Create a new StorageClass named local-kiddie with the provisioner rancher.io/local-path."
echo -e "Set the volumeBindingMode to WaitForFirstConsumer"
echo -e "Configure the StorageClass as te default StorageClass."
echo -e "Do not modify any existing Depoyments or PersistentVolumeClaims"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. StorageClass 생성 확인
SC_CHECK=$(kubectl get sc local-kiddie --no-headers 2>/dev/null)
if [[ "$SC_CHECK" == *"local-kiddie"* ]]; then
    echo -e "1. StorageClass (local-kiddie): ${GREEN}PASS${NC}"
else
    echo -e "1. StorageClass (local-kiddie): ${RED}FAIL${NC}"
fi

# 2. Provisioner 및 BindingMode 확인
PROVISIONER=$(kubectl get sc local-kiddie -o jsonpath='{.provisioner}' 2>/dev/null)
BINDING_MODE=$(kubectl get sc local-kiddie -o jsonpath='{.volumeBindingMode}' 2>/dev/null)

if [ "$PROVISIONER" == "rancher.io/local-path" ] && [ "$BINDING_MODE" == "WaitForFirstConsumer" ]; then
    echo -e "2. Provisioner & BindingMode: ${GREEN}PASS${NC}"
else
    echo -e "2. Provisioner & BindingMode: ${RED}FAIL${NC}"
fi

# 3. Default 설정 확인
IS_DEFAULT=$(kubectl get sc local-kiddie -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null)
if [ "$IS_DEFAULT" == "true" ]; then
    echo -e "3. Default StorageClass: ${GREEN}PASS${NC}"
else
    echo -e "3. Default StorageClass: ${RED}FAIL${NC}"
fi