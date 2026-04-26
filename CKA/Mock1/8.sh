#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"

# cert-manager CRD들이 존재하도록 환경 구축
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.crds.yaml &> /dev/null

echo -e "${GREEN}환경 구축 완료 (cert-manager CRDs 설치됨).${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 08 CRD's"
echo ""
echo -e "Task:"
echo -e "1. Create a list of all cert-manager [CRDs] and save it to ~/resources.yaml"
echo -e "   Make sure kubectl's use default output format and use kubectl to list CRD's"
echo ""
echo -e "2. Using kubectl, extract the documentation for the subject specification field of the Certificate Custom Resource"
echo -e "   and save it to ~/subject.yaml"
echo ""
echo -e "You may use any output format that kubectl supports."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. ~/resources.yaml 검증 (cert-manager 단어가 포함된 CRD 리스트인지 확인)
if [ -f "$HOME/resources.yaml" ] && grep -q "cert-manager.io" "$HOME/resources.yaml"; then
    echo -e "1. cert-manager CRD List (~/resources.yaml): ${GREEN}PASS${NC}"
else
    echo -e "1. cert-manager CRD List (~/resources.yaml): ${RED}FAIL${NC}"
fi

# 2. ~/subject.yaml 검증 (Certificate의 subject 필드 관련 설명이 포함되었는지 확인)
if [ -f "$HOME/subject.yaml" ] && grep -q "subject" "$HOME/subject.yaml"; then
    echo -e "2. Certificate Subject Documentation (~/subject.yaml): ${GREEN}PASS${NC}"
else
    echo -e "2. Certificate Subject Documentation (~/subject.yaml): ${RED}FAIL${NC}"
fi