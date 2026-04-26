#!/bin/bash

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== [1] 환경 준비 (Setup) ===${NC}"

# 1. 시뮬레이션을 위한 데비안 패키지 파일 생성
touch ~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb

# 2. 기존 설정 초기화 (실습을 위해 0으로 설정)
sudo sysctl -w net.bridge.bridge-nf-call-iptables=0 &> /dev/null
sudo sysctl -w net.ipv6.conf.all.forwarding=0 &> /dev/null
sudo sysctl -w net.ipv4.ip_forward=0 &> /dev/null

echo -e "${GREEN}환경 준비 완료: ~/cri-dockerd...deb 파일이 생성되었으며 시스템 파라미터가 초기화되었습니다.${NC}"
echo ""

echo -e "${BLUE}=== [2] 문제 (Question 13) ===${NC}"
echo -e "Tasks:"
echo -e "1. Install the Debian package ~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb using dpkg."
echo -e "2. Enable and start the cri-docker service."
echo -e "3. Configure these system parameters:"
echo -e "   - Set net.bridge.bridge-nf-call-iptables to 1"
echo -e "   - Set net.ipv6.conf.all.forwarding to 1"
echo -e "   - Set net.ipv4.ip_forward to 1"
echo -e "   - Set net.netfilter.nf_conntrack_max to 131072"
echo ""
echo -e "${BLUE}-------------------------------------------------------${NC}"
echo -e "작업을 모두 완료한 후 Enter를 누르면 검증을 시작합니다..."
read

echo -e "${BLUE}=== [3] 결과 검증 (Validation) ===${NC}"

# 1. 패키지 설치 여부 확인
DPKG_STATUS=$(dpkg -l | grep cri-dockerd | awk '{print $1}')
if [[ "$DPKG_STATUS" == "ii" ]]; then
    echo -e "1. cri-dockerd Package Installed: ${GREEN}PASS${NC}"
else
    echo -e "1. cri-dockerd Package Installed: ${RED}FAIL (dpkg -i 명령어로 설치하세요)${NC}"
fi

# 2. 서비스 상태 확인
SERVICE_ACTIVE=$(systemctl is-active cri-docker 2>/dev/null)
if [[ "$SERVICE_ACTIVE" == "active" ]]; then
    echo -e "2. cri-docker Service Active: ${GREEN}PASS${NC}"
else
    echo -e "2. cri-docker Service Active: ${RED}FAIL (service를 start/enable 하세요)${NC}"
fi

# 3. 시스템 파라미터 검증
check_sysctl() {
    PARAM=$1
    EXPECTED=$2
    ACTUAL=$(sysctl -n $PARAM 2>/dev/null)
    if [[ "$ACTUAL" == "$EXPECTED" ]]; then
        echo -e "3. $PARAM ($EXPECTED): ${GREEN}PASS${NC}"
    else
        echo -e "3. $PARAM ($EXPECTED): ${RED}FAIL (현재값: $ACTUAL)${NC}"
    fi
}

check_sysctl "net.bridge.bridge-nf-call-iptables" "1"
check_sysctl "net.ipv6.conf.all.forwarding" "1"
check_sysctl "net.ipv4.ip_forward" "1"
check_sysctl "net.netfilter.nf_conntrack_max" "131072"

echo ""
echo -e "${BLUE}팁: 설정이 재부팅 후에도 유지되도록 /etc/sysctl.conf에 기록했는지 확인하세요.${NC}"