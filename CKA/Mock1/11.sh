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
echo -e "문제를 풀고 나서 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. CNI 설치 여부 확인 (기본적인 pod 상태 확인)
CNI_PODS=$(kubectl get pods -n kube-system | grep -E 'flannel|calico' | grep 'Running' | wc -l)

if [ "$CNI_PODS" -gt 0 ]; then
    echo -e "1. CNI Pods Running: ${GREEN}PASS${NC}"
else
    echo -e "1. CNI Pods Running: ${RED}FAIL (설치된 CNI Pod를 찾을 수 없거나 실행 중이 아닙니다)${NC}"
fi

# 2. 요구사항 검증 (Network Policy 지원 여부)
# Flannel은 기본적으로 Network Policy를 지원하지 않으므로 Calico 설치 여부를 중점적으로 확인
IS_CALICO=$(kubectl get pods -n kube-system | grep 'calico' | wc -l)

if [ "$IS_CALICO" -gt 0 ]; then
    echo -e "2. Support Network Policy: ${GREEN}PASS${NC} (Calico detected)"
else
    # Flannel인 경우 경고 메시지
    IS_FLANNEL=$(kubectl get pods -n kube-system | grep 'flannel' | wc -l)
    if [ "$IS_FLANNEL" -gt 0 ]; then
        echo -e "2. Support Network Policy: ${RED}FAIL${NC} (Flannel does not support Network Policy by default)"
    else
        echo -e "2. Support Network Policy: ${RED}FAIL (No CNI detected)${NC}"
    fi
fi

# 3. 노드 Ready 상태 확인
NODE_READY=$(kubectl get nodes | grep ' Ready ' | wc -l)
if [ "$NODE_READY" -gt 0 ]; then
    echo -e "3. Node Status Ready: ${GREEN}PASS${NC}"
else
    echo -e "3. Node Status Ready: ${RED}FAIL (노드가 Ready 상태가 아닙니다)${NC}"
fi