#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 준비 (Preparation) ===${NC}"

# 기존 CNI 설정이 있다면 삭제 (실습을 위해 클린한 상태 유도)
# 주의: 실제 운영 환경에서는 실행하지 마세요.
echo "기존 네트워크 설정 확인 중..."
sudo rm -rf /etc/cni/net.d/* &> /dev/null

echo -e "${GREEN}환경 준비 완료. CNI가 설치되지 않은 상태입니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question) ===${NC}"
echo -e "QUESTION: 11 Container Network Interface [CNI]"
echo -e "Install and configure a CNI of your choice that meet the specified requirements,"
echo -e "choose one of the following;"
echo ""
echo -e "1. Flannel (v0.26.1) using the manifest: [kube-flannel.yml]"
echo -e "   (https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml)"
echo ""
echo -e "2. Calico (v3.28.2) using the manifest: [tigera-operator.yaml]"
echo -e "   (https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml)"
echo ""
echo -e "The CNI you choose must:"
echo -e "1. Let pods communicate with eachother"
echo -e "2. Support network policy enforcement"
echo -e "3. Install from manifest"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
