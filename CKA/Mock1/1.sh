#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 구축 (Setup) ===${NC}"
# 네임스페이스 및 경로 준비
kubectl create ns argocd --dry-run=client -o yaml | kubectl apply -f -
sudo mkdir -p /home/argo
sudo chown $(whoami):$(whoami) /home/argo

echo -e "${GREEN}환경 구축이 완료되었습니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "1. Install Argo CD in a Kubernetes cluster using Helm while ensuring that CRDs are not installed (as they are pre-installed). Follow the steps below:"
echo ""
echo -e "Requirements:"
echo -e "- Add the official Argo CD Helm repository with the name argo."
echo -e "- Generate a Helm template from the Argo CD chart version 7.7.3 for the argocd namespace."
echo -e "- Ensure that CRDs are not installed by configuring the chart accordingly."
echo -e "- Save the generated YAML manifest to /home/argo/argo-helm.yaml."
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "문제를 모두 풀었다면 Enter를 눌러 결과를 검증하세요..."
