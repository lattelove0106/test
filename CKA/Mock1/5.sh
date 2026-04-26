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
